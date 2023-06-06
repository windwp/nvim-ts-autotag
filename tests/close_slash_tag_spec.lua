if not _G.test_close then
    return
end

local ts = require('nvim-treesitter.configs')
local helpers = {}
ts.setup({
    ensure_installed = _G.ts_filetypes,
    highlight = { enable = true },
})
local eq = assert.are.same

function helpers.feed(text, feed_opts)
    feed_opts = feed_opts or 'n'
    local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
    vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
    helpers.feed('a' .. text, 'x')
end

local data = {
    {
        name = '1 html close tag after inputting /',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[/]],
        before = [[<div><| ]],
        after = [[<div></div>|]],
    },
    {
        name = '2 html close tag after inputting /',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[/]],
        before = [[<div clas="laa"><| ]],
        after = [[<div clas="laa"></div>|]],
    },
    {
        name = '3 html don\'t close tag when no opening tag is found',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[/>]],
        before = [[<div><|</div> ]],
        after = [[<div></>|</div>]],
    },
    {
        name = '4 html not close inside quote',
        filepath = './sample/index.html',
        filetype = 'html',
        linenr = 10,
        key = [[/]],
        before = [[<div class="aa|"> </div>  ]],
        after = [[<div class="aa/|"> </div>  ]],
    },
    {
        name = '5 typescriptreact close tag after inputting /',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[/]],
        before = [[<Img><| ]],
        after = [[<Img></Img>| ]],
    },
    {
        name = '6 typescriptreact close after inputting /',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[/]],
        before = [[<div class="abc"><| ]],
        after = [[<div class="abc"></div>| ]],
    },
    {
        name = '7 typescriptreact close on inline script after inputting /',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 9,
        key = [[/]],
        before = [[const a = () => <div><| ]],
        after = [[const a = () => <div></div>| ]],
    },
    {
        name = '8 typescriptreact not close on close tag',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[/]],
        before = [[<button className="btn " onClick={()}> <| ]],
        after = [[<button className="btn " onClick={()}> </button>| ]],
    },
    {
        name = '9 typescriptreact not close on expresion',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[/]],
        before = [[<button className="btn " onClick={(|)}> </button> ]],
        after = [[<button className="btn " onClick={(/|)}> </button> ]],
    },
    {
        name = '10 typescriptreact not close on typescript',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 6,
        key = [[/]],
        before = [[const data:Array<string| ]],
        after = [[const data:Array<string/| ]],
    },
    {
        name = '11 typescriptreact not close on script',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 6,
        key = [[/]],
        before = [[{(card.data | 0) && <div></div>}]],
        after = [[{(card.data /| 0) && <div></div>}]],
    },
    {
        name = '12 vue close tag after inputting /',
        filepath = './sample/index.vue',
        filetype = 'vue',
        linenr = 4,
        key = [[/]],
        before = [[<Img><| ]],
        after = [[<Img></Img>|]],
    },
    {
        name = '13 vue not close on script',
        filepath = './sample/index.vue',
        filetype = 'vue',
        linenr = 12,
        key = [[/]],
        before = [[const data:Array<string| ]],
        after = [[const data:Array<string/| ]],
    },
    {
        name = '14 typescriptreact nested indentifer close after inputting /',
        filepath = './sample/index.tsx',
        filetype = 'typescriptreact',
        linenr = 12,
        key = [[/]],
        before = [[<Opt.Input><| ]],
        after = [[<Opt.Input></Opt.Input>| ]],
    },
    {
        name = '15 php close tag after inputting /',
        filepath = './sample/index.php',
        filetype = 'php',
        linenr = 25,
        key = [[/]],
        before = [[<div><| ]],
        after = [[<div></div>| ]],
    },
    {
        name = '16 lit template div close after inputting /',
        filepath = './sample/index.ts',
        filetype = 'typescript',
        linenr = 3,
        key = [[/]],
        before = [[<div><| ]],
        after = [[<div></div>| ]],
    },
    {
        name = '17 eruby template div close after inputting /',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[/]],
        before = [[<div><| ]],
        after = [[<div></div>| ]],
    },
    {
        name = '18 eruby template ruby string write raw /',
        filepath = './sample/index.html.erb',
        filetype = 'eruby',
        linenr = 10,
        key = [[/]],
        before = [[<%= <div| %>]],
        after = [[<%= <div/| %> ]],
    },
}

local autotag = require('nvim-ts-autotag')
autotag.test = true
local run_data = _G.Test_filter(data)

describe('[close slash tag]', function()
    _G.Test_withfile(run_data, {
        mode = 'i',
        cursor_add = 0,
        before_each = function(value) end,
    })
end)
