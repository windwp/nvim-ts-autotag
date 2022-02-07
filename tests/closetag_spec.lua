
if not _G.test_close then
  return
end

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
local ts = require 'nvim-treesitter.configs'
local helpers = {}

parser_config.rescript = {
  install_info = {
    url = "https://github.com/nkrkv/nvim-treesitter-rescript",
    files = {"src/parser.c", "src/scanner.c"},
    branch = "main",
  },
  maintainers = { "@nkrkv" },
  filetype = "rescript",
}


ts.setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
}
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
    name     = "1 html close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div|]],
    after    = [[<div>|</div>]]
  },
  {
    name     = "2 html close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div clas="laa"|]],
    after    = [[<div clas="laa">|</div>]]
  },
  {
    name     = "3 html not close tag on close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div>aa</div|]],
    after    = [[<div>aa</div>|]]
  },
  {
    name     = "4 html not close on input tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<input| ]],
    after    = [[<input>| ]]
  },
  {
    name     = "5 html not close inside quote" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div class="aa|"> </div>  ]],
    after    = [[<div class="aa>|"> </div>  ]]
  },
  {
    name     = "6 html not close on exist tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div><div|</div></div>]],
    after    = [[<div><div>|</div></div>]]
  },
  {
    name     = "7 typescriptreact close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<Img|]],
    after    = [[<Img>|</Img>]]
  },
  {
    name     = "8 typescriptreact close" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<div class="abc"|]],
    after    = [[<div class="abc">|</div>]]
  },
  {
    name     = "9 typescriptreact not close on exist tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<div><div|</div></div>]],
    after    = [[<div><div>|</div></div>]]
  },
  {
    name     = "10 typescriptreact close on inline script" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 9,
    key      = [[>]],
    before   = [[const a = () => <div|]],
    after    = [[const a = () => <div>|</div>]]
  },
  {

    name     = "11 typescriptreact not close on close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<button className="btn " onClick={()}> </button|]],
    after    = [[<button className="btn " onClick={()}> </button>|]]
  },
  {
    name     = "12 typescriptreact not close on expresion" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<button className="btn " onClick={(|)}> </button> ]],
    after    = [[<button className="btn " onClick={(>|)}> </button> ]]
  },
  {
    name     = "13 typescriptreact not close on typescript" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 6,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string>| ]]
  },

  {
    name     = "14 typescriptreact not close on script" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 6,
    key      = [[>]],
    before   = [[{(card.data | 0) && <div></div>}]],
    after    = [[{(card.data >| 0) && <div></div>}]]
  },
  {
    name     = "15 vue auto close tag" ,
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 4,
    key      = [[>]],
    before   = [[<Img|]],
    after    = [[<Img>|</Img>]]
  },
  {
    name     = "16 vue not close on script",
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 12,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string>| ]]
  },
  {
    name     = "17 typescriptreact nested indentifer " ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<Opt.Input| ]],
    after    = [[<Opt.Input>|</Opt.Input> ]]
  },
  {
    name     = "18 php div " ,
    filepath = './sample/index.php',
    filetype = "php",
    linenr   = 25,
    key      = [[>]],
    before   = [[<div| ]],
    after    = [[<div>|</div> ]]
  },
  {
    name = "19 rescript close tag",
    filepath = './sample/index.res',
    filetype = 'rescript',
    linenr = 12,
    key = [[>]],
    before = [[<Img|]],
    after = [[<Img>|</Img>]]
  },
  {
    name = "20 rescript close",
    filepath = './sample/index.res',
    filetype = 'rescript',
    linenr = 13,
    key = [[>]],
    before   = [[<div class="abc"|]],
    after    = [[<div class="abc">|</div>]],
  },
  {
    name     = "21 rescript not close on exist tag" ,
    filepath = './sample/index.res',
    filetype = "rescript",
    linenr   = 14,
    key      = [[>]],
    before   = [[<div><div|</div></div>]],
    after    = [[<div><div>|</div></div>]]
  },
  {
    name     = "22 rescript not close on close tag" ,
    filepath = './sample/index.res',
    filetype = "rescript",
    linenr   = 15,
    key      = [[>]],
    before   = [[<button onClick> </button|]],
    after    = [[<button onClick> </button>|]]
  },
  {
    name     = "23 rescrpt not close on expresion" ,
    filepath = './sample/index.res',
    filetype = "rescript",
    linenr   = 15,
    key      = [[>]],
    before   = [[<button onClick>{|}</button> ]],
    after    = [[<button onClick>{>|}</button> ]]
  },
}
local run_data = {}
for _, value in pairs(data) do
  if value.only == true then
    table.insert(run_data, value)
    break
  end
end
if #run_data == 0 then run_data = data end

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU=ts_utils

local function Test(test_data)
  for _, value in pairs(test_data) do
    it("test "..value.name, function()
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '%|')
      local line =value.linenr
      if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
        vim.cmd(":bd!")
        vim.cmd(":e " .. value.filepath)
        vim.bo.filetype = value.filetype
        vim.fn.setline(line , before)
        vim.fn.cursor(line, p_before -1)
        -- autotag.closeTag()
        helpers.insert(value.key)
        local result = vim.fn.getline(line)
        local pos = vim.fn.getpos('.')
        eq(after, result , "\n\n [ERROR TEXT]: " .. value.name .. "\n")
        eq(p_after, pos[3] +1, "\n\n [ERROR POS]: " .. value.name .. "\n")
      else
        eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
      end
    end)
  end
end

describe('[close tag]', function()
  Test(run_data)
end)
