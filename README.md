# nvim-ts-autotag

Use treesitter to **autoclose** and **autorename** html tag

It works with:

- astro
- glimmer
- handlebars
- html
- javascript
- jsx
- liquid
- markdown
- php
- rescript
- svelte
- tsx
- twig
- typescript
- vue
- xml

and more

## Usage

```text
Before        Input         After
------------------------------------
<div           >              <div></div>
<div></div>    ciwspan<esc>   <span></span>
------------------------------------
```

## Setup

Requires `Nvim 0.9.5` and up.

Note that `nvim-ts-autotag` will not work unless you have treesitter parsers (like `html`) installed for a given
filetype. See [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for installing parsers.

```lua
require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    ["html"] = {
      enable_close = false
    }
  }
})
```

> [!CAUTION]
> If you are setting up via `nvim-treesitter.configs` it has been deprecated! Please migrate to the
> new way. It will be removed in `1.0.0`.

### A note on lazy loading

For those of you using lazy loading through a plugin manager (like [lazy.nvim](https://github.com/folke/lazy.nvim)) lazy
loading is not particularly necessary for this plugin. `nvim-ts-autotag` is efficient in choosing when it needs to load.
If you still insist on lazy loading `nvim-ts-autotag`, then two good events to use are `BufReadPre` & `BufNewFile`.

### Extending the default config

Let's say that there's a language that `nvim-ts-autotag` doesn't currently support and you'd like to support it in your
config. While it would be the preference of the author that you upstream your changes, perhaps you would rather not 😢.

For example, if you have a language that has a very similar layout in its Treesitter Queries as `html`, you could add an
alias like so:

```lua
require('nvim-ts-autotag').setup({
  aliases = {
    ["your language here"] = "html",
  }
})

-- or
local TagConfigs = require("nvim-ts-autotag.config.init")
TagConfigs:add_alias("your language here", "html")
```

That will make `nvim-ts-autotag` close tags according to the rules of the `html` config in the given language.

But what if a parser breaks for whatever reason, for example the upstream Treesitter tree changes its node names and now
the default queries that `nvim-ts-autotag` provides no longer work.

Fear not! You can directly extend and override the existing configs. For example, let's say the start and end tag
patterns have changed for `xml`. We can directly override the `xml` config:

```lua
local TagConfigs = require("nvim-ts-autotag.config.init")
TagConfigs:update(TagConfigs:get("xml"):override("xml", {
    start_tag_pattern = { "STag" },
    end_tag_pattern = { "ETag" },
}))
```

In fact, this very nearly what we do during our own internal initialization phase for `nvim-ts-autotag`.

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
## Contributors
Thank [@PriceHiller](https://github.com/PriceHiller) for his work on this plugin.

## Sponsor
If you find this plugin useful, please consider sponsoring the project.

[Sponsor](https://paypal.me/trieule1vn)
