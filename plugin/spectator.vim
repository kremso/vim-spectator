if exists('g:loaded_spectator') || &cp
  finish
endif

function s:InLib(path)
  return match(a:path, '^lib/') != -1
endfunction

function! s:AlternateFile(path) abort
  let l:in_spec = match(expand("%"), '^spec/') != -1
  if l:in_spec
    return s:AlternateToSpec(a:path)
  else
    return s:AlternateToNonSpec(a:path)
  endif
endfunction

function! s:AlternateToNonSpec(path) abort
  let path = fnamemodify(a:path, ':h')
  let spec_name = substitute(fnamemodify(a:path, ':t'), '\.rb$', '_spec.rb', '')
  let path_minus_app = substitute(path, '^app/', '', '')
  return 'spec/' . path_minus_app . '/' . spec_name
endfunction

function! s:AlternateToSpec(path) abort
  let path = substitute(fnamemodify(a:path, ':h'), '^spec/', '', '')
  let file_name = substitute(fnamemodify(a:path, ':t'), '_spec\.rb$', '.rb', '')

  if !s:InLib(path)
    let path = 'app/' . path
  endif

  return path . '/' . file_name
endfunction

function! AutoCreateRspec()
  let alternate = s:AlternateFile(expand('%'))

  if filereadable(alternate)
    execute "edit " . alternate
  else
    if confirm("Spec file '" . alternate . "' does not exist", "&Create it\nor &Abort?") == 2
      return
    endif

    let spec_dir = fnamemodify(alternate, ':h')
    if !isdirectory(spec_dir)
      call mkdir(spec_dir, 'p')
    end
    let skeleton = s:SpecSkeleton(expand('%'))

    execute "silent edit " . alternate
    execute "silent normal! i" . skeleton
    execute "silent normal! ggVG="
    execute "silent write"
    execute "/it"
    execute "normal! 2f'"
    startinsert
  endif
endfunction

function s:StripRailsLocation(path)
  if s:InLib(a:path)
    return substitute(a:path, '^lib/', '', '')
  else
    return substitute(a:path, '^app/.\{-}/', '', '') "\{-} means non-greedy
  endif
endfunction

function! s:Gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:Camelize(str)
  let str = s:Gsub(a:str,'/(.=)','::\u\1')
  let str = s:Gsub(str,'%([_-]|<)(.)','\u\1')
  return str
endfunction

function! s:SpecSkeleton(path) abort
  let path = substitute(a:path, '.rb', '', '')
  let template = ''

  if s:InLib(path)
    let template .= "require '" . path . "'\n\n"
  else
    let template .= "require 'spec_helper'\n\n"
  endif

  let non_rails_path = s:StripRailsLocation(fnamemodify(path, ':h'))
  let directories = split(non_rails_path, '/')
  let modules = map(directories, 's:Camelize(v:val)')

  let class_name = s:Camelize(fnamemodify(path, ':t'))

  let template .= 'module ' . join(modules, '::') . "\n"
  let template .= "describe " . class_name . " do\n"
  let template .= "it '' do\n"
  let template .= "end\n"
  let template .= "end\n"
  let template .= "end"

  return template
endfunction

augroup AutoCreateRSpec
  au!
  autocmd FileType ruby :cnoremap A<cr> call AutoCreateRspec()<cr>
augroup END

let g:loaded_spectator = 1
