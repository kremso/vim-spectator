# spectator.vim

[vim-rails](https://github.com/tpope/vim-rails) provides `:A` command that alternates between code and tests. Unfortunately, it [only works if the alternate file exists](https://github.com/tpope/vim-rails/issues/135) and this is not likely to change.

spectator.vim complements rails.vim and overrides its `:A` command. If the alternate file exists, the behavior is the same as with rails.vim. If the alternate file does not exist, it is created and populated with skeleton code. Let's see.

Start with a new file, say  `lib/search/es/mapper.rb`. press `:A` and spectator.vim will create the corresponding spec file in `spec/lib/search/es/mapper_spec.rb` and populate it with

```
require 'search/es/mapper'

module Search::Es
  describe Mapper do
    it '' do
    end
  end
end
```

Notice that spectator.vim detects modules and requires the spec'd file. It is also smart enough to handle files in `app`. When you are in `app/controllers/api/v2/fields_controller.rb` and press `:A`, spectator.vim creates new spec in `spec/controllers/api/v2/fields_controller_spec.rb` and populates it with

```
require 'spec_helper'

module Api::V2
  describe FieldsController do
    it '' do
    end
  end
end
```

## Limitations

- Only handles rspec
