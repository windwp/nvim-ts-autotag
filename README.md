# nvim-ts-closetag
Use treesitter to autoclose xml tag

it work well with tsx

## Usage

``` text
Before        Input         After
------------------------------------
<div           >         <div></div> 
------------------------------------
```

## Setup
Neovim 0.5 with and nvim-treesitter to work

``` lua
require('nvim-ts-closetag').setup()
```

## Default values

``` lua
local filetypes = {
  'html', 'xml', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
}
local skip_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
}

```

### Override default values

``` lua
require('nvim-ts-closetag').setup({
  filetypes = { "html" , "xml" },
})
```

# Ref
[vim-closetag](https://github.com/alvan/vim-closetag/edit/master/README.md)
