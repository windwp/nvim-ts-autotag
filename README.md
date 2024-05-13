# nvim-ts-autotag

Use treesitter to **autoclose** and **autorename** html tag

It works with:

- astro
- glimmer
- handlebars
- html
- javascript
- jsx
- markdown
- php
- rescript
- svelte
- tsx
- typescript
- vue
- xml

## Usage

``` text
Before        Input         After
------------------------------------
<div           >              <div></div>
<div></div>    ciwspan<esc>   <span></span>
------------------------------------
```


## Setup
Neovim 0.7 and nvim-treesitter to work

User treesitter setup
```lua
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}

```
or you can use a set up function

``` lua
require('nvim-ts-autotag').setup()

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
    'astro', 'glimmer', 'handlebars', 'hbs'
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
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
    filetypes = { "html" , "xml" },
  }
}
-- OR
require('nvim-ts-autotag').setup({
  filetypes = { "html" , "xml" },
})

```

## Fork Status
This is forked from https://github.com/windwp/nvim-ts-autotag due to the primary maintainer's disappearance. Any
PRs/work given to this fork *may* end up back in the original repository if the primary maintainer comes back.

Full credit to [@windwp](https://github.com/windwp) for the creation of this plugin. Here's to hoping they're ok and will be back sometime down the line.
