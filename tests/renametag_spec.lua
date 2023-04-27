local ts = require 'nvim-treesitter.configs'

local log = require('nvim-ts-autotag._log')

if not _G.test_rename then
    return
end

local helpers = {}
ts.setup({
    ensure_installed = _G.ts_filetypes,
    highlight = {
        use_languagetree = true,
        enable = true,
    },
    fold = { enable = false },
})

function helpers.feed(text, feed_opts)
    feed_opts = feed_opts or 'n'
    local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
    vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
    helpers.feed('i' .. text, 'x')
end

local data = {
    {
        name = 'html rename open tag',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<di|v> dsadsa </div> ]],
        after = [[<lala|> dsadsa </lala> ]],
    },
    {
        name = 'html rename open tag with attr',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<di|v class="lla"> dsadsa </div> ]],
        after = [[<lala| class="lla"> dsadsa </lala|> ]],
    },
    {
        name = 'html rename close tag with attr',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<div class="lla"> dsadsa </di|v> ]],
        after = [[<lala class="lla"> dsadsa </lal|a> ]],
    },
    {
        name = 'html not rename close tag on char <',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[i<]],
        before = [[<div class="lla"> dsadsa |/button> ]],
        after = [[<div class="lla"> dsadsa <|/button> ]],
    },
    {

        name = 'html not rename close tag with not valid',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            [[<di|v class="lla" ]],
            [[ dsadsa </div>]],
        },
        after = [[<lala class="lla" ]],
    },
    --   {
    --     only=true,
    --     name     = "html not rename close tag if it have parent node map with child nod" ,
    --     filepath = './sample/index.html',
    --     filetype = "html",
    --     linenr   = 12,
    --     key      = [[ciwlala]],
    --     before   = {
    --       [[<d|iv> </div>]],
    --       [[<div>  </div>"]]
    --     },
    --     after    = [[<d|iv> </div>]]
    --   },
    {

        name = 'html not rename close tag with not valid',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            [[<div class="lla" </d|iv>]],
        },
        after = [[<div class="lla" </lala|>]],
    },
    {
        name = 'typescriptreact rename open tag',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ciwlala]],
        before = [[<di|v> dsadsa </div> ]],
        after = [[<lala|> dsadsa </lala> ]],
    },
    {
        name = 'typescriptreact rename open tag with attr',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ciwlala]],
        before = [[<di|v class="lla"> dsadsa </div> ]],
        after = [[<lala| class="lla"> dsadsa </lala> ]],
    },
    {
        name = 'typescriptreact rename close tag with attr',
        filepath = './sample/index.tsx',
        filetype = 'html',
        linenr = 12,
        key = [[ciwlala]],
        before = [[<div class="lla"> dsadsa </di|v> ]],
        after = [[<lala class="lla"> dsadsa </lal|a>  ]],
    },
    {
        name = '17 typescriptreact nested indentifer ',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ciwlala]],
        before = [[<Opt.In|put></Opt.Input> ]],
        after = [[<Opt.lala|></Opt.lala> ]],
    },
    {
        name = '18 rename empty node ',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ilala]],
        before = [[<|><div></div></>]],
        after = [[<lala|><div></div></lala>]],
    },
    {
        name = '19 rename start tag on svelte ',
        filepath = './sample/index.svelte',
        filetype = 'svelte',
        linenr = 18,
        key = [[ciwlala]],
        before = [[<|data></data>]],
        after = [[<lala|></lala>]],
    },
    {
        name = '20 rename end tag on svelte ',
        filepath = './sample/index.svelte',
        filetype = 'svelte',
        linenr = 18,
        key = [[ciwlala]],
        before = [[<span></spa|n>]],
        after = [[<lala></lala>]],
    },
    {
        name     = "21 rescript rename open tag",
        filepath = './sample/index.res',
        filetype = "rescript",
        linenr   = 12,
        key      = [[ciwlala]],
        before   = [[<di|v> dsadsa </div> ]],
        after    = [[<lala|> dsadsa </lala> ]]
    },
    {
        name     = "22 rescript rename open tag with attr",
        filepath = './sample/index.res',
        filetype = "rescript",
        linenr   = 12,
        key      = [[ciwlala]],
        before   = [[<di|v class="lla"> dsadsa </div> ]],
        after    = [[<lala| class="lla"> dsadsa </lala> ]]
    },
    {
        name     = "23 rescript rename close tag with attr",
        filepath = './sample/index.res',
        filetype = "rescript",
        linenr   = 12,
        key      = [[ciwlala]],
        before   = [[<div class="lla"> dsadsa </di|v> ]],
        after    = [[<lala class="lla"> dsadsa </lal|a> ]]
    },
    {
        name = '24 test check rename same with parent',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = 'ciwkey',
        before = {
            '<Container>',
            '    <di|v>',
            '',
            '    <span></span>',
            '</Container>',
        },
        after = {
            '<Container>',
            '    <key>',
            '',
            '    <span></span>',
            '</Container>',
        },
    },
    {
        name = '25 rename start have same node with parent',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            '<div>',
            '   <di|v>',
            '    <span>test </span>',
            '   </div>',
            '</div>',
        },
        after = {
            '<div>',
            '   <lala>',
            '    <span>test </span>',
            '   </lala>',
            '</div>',
        },
    },
    {
        name = '26 rename should not rename tag on attribute node',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            '<div>',
            '<Navbar className="|a">',
            '  <div className="flex flex-col">',
            '    <div className="flex flex-row">',
            '    </div>',
            '  </div>',
            '</div>',
        },
        after = {
            '<div>',
            '<Navbar className="lala">',
            '  <div className="flex flex-col">',
            '    <div className="flex flex-row">',
            '    </div>',
            '  </div>',
            '</div>',
        },
    },
    {
        name = 'eruby rename open tag',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<di|v> dsadsa </div> ]],
        after = [[<lala|> dsadsa </lala> ]],
    },
    {
        name = 'eruby rename open tag with attr',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<di|v class="lla"> dsadsa </div> ]],
        after = [[<lala| class="lla"> dsadsa </lala|> ]],
    },
    {
        name = 'eruby rename close tag with attr',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[ciwlala]],
        before = [[<div class="lla"> dsadsa </di|v> ]],
        after = [[<lala class="lla"> dsadsa </lal|a> ]],
    },
    {
        name = 'eruby not rename close tag on char <',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[i<]],
        before = [[<div class="lla"> dsadsa |/button> ]],
        after = [[<div class="lla"> dsadsa <|/button> ]],
    },
    {
        name = 'eruby not rename close tag with not valid',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            [[<di|v class="lla" ]],
            [[ dsadsa </div>]],
        },
        after = [[<lala class="lla" ]],
    },
    {
        name = 'eruby not rename close tag with not valid',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            [[<div class="lla" </d|iv>]],
        },
        after = [[<div class="lla" </lala|>]],
    },
    {
        name = 'eruby not rename tag-like ruby string',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 12,
        key = [[ciwlala]],
        before = {
            [[<%= <div></d|iv> %>]],
        },
        after = [[<%= <div></lala|> %>]],
    },
}

local autotag = require('nvim-ts-autotag')
autotag.test = true

local run_data = _G.Test_filter(data)

describe('[rename tag]', function()
    _G.Test_withfile(run_data, {
        cursor_add = 0,
        before_each = function(value) end,
    })
end)
