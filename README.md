# nvim-ts-autotag

Uses the treesitter incremental parser to intelligently **autoclose** and **autorename** html tags as you edit.

It works with html,tsx,vue,svelte,php,rescript.

## Usage

Tags are automatically paired as you type in insert mode, and if you renamed one tag its matching pair will update when you exit insert mode.

``` text
Before        Input         After
------------------------------------
<div           >              <div></div>
<div></div>    ciwspan<esc>   <span></span>
------------------------------------
```


## Setup

This plugin requires Neovim 0.5 or greater and [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to work

Configure in your treesitter setup:

```lua
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}

```
or you can use a set up function:

``` lua
require('nvim-ts-autotag').setup()

```

And make sure you have the html treesitter installed:

```
  :TSInstall html
```

### Enable update on insert

If you have that issue
[#19](https://github.com/windwp/nvim-ts-autotag/issues/19)

```lua
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        underline = true,
        virtual_text = {
            spacing = 5,
            severity_limit = 'Warning',
        },
        update_in_insert = true,
    }
)
```
## Default values

``` lua
local filetypes = {
    'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx', 'rescript',
    'xml',
    'php',
    'markdown',
    'glimmer','handlebars','hbs'
}
local skip_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
}

```

### Override default values

``` lua

require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
    filetypes = { "html" , "xml" },
  }
}
-- OR
require('nvim-ts-autotag').setup({
  filetypes = { "html" , "xml" },
})

```
