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

### Enable Treesitter in XML files

nvim-treesitter [doesn't have an XML parser](https://github.com/nvim-treesitter/nvim-treesitter/issues/3295). Instead you can configure treesitter to use the HTML parser, which isn't perfect but works fine.
```lua
-- Use the HTML parser for XML files
vim.treesitter.language.register("html", "xml")
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

## Sponsor
If you find this plugin useful, please consider sponsoring the project.

[Sponsor](https://paypal.me/trieule1vn)
