local ts = require 'nvim-treesitter.configs'
local helpers = {}
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
    name     = "html close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div|]],
    after    = [[<div>|</div>]]
  },
  {
    name     = "html close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div clas="laa"|]],
    after    = [[<div clas="laa">|</div>]]
  },
  {
    name     = "html not close tag on close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div>aa</div|]],
    after    = [[<div>aa</div>|]]
  },
  {
    name     = "html not close on input tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<input| ]],
    after    = [[<input>| ]]
  },
  {
    name     = "html not close inside quote" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div class="aa|"> </div>  ]],
    after    = [[<div class="aa>|"> </div>  ]]
  },
  {
    name     = "html not close on exist tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div|</div>]],
    after    = [[<div>|</div>]]
  },
  {
    name     = "typescriptreact close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<Img|]],
    after    = [[<Img>|</Img>]]
  },
  {
    name     = "typescriptreact not close on exist tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<div|]],
    after    = [[<div>|</div>]]
  },
  {
    name     = "typescriptreact not close on exist tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[const a = () => <div|]],
    after    = [[const a = () => <div>|</div>]]
  },

  {
    name     = "typescriptreact close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<Img|]],
    after    = [[<Img>|</Img>]]
  },
  {
    name     = "typescriptreact not close on close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<button className="btn " onClick={()}> </button|]],
    after    = [[<button className="btn " onClick={()}> </button>|]]
  },
  {
    name     = "typescriptreact not close on expresion" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<button className="btn " onClick={(|)}> </button> ]],
    after    = [[<button className="btn " onClick={(>|)}> </button> ]]
  },
  {
    name     = "typescriptreact not close on script" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 6,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string>| ]]
  },

  {
    name     = "typescriptreact not close on script" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 6,
    key      = [[>]],
    before   = [[{(card.data | 0) && <div></div>}]],
    after    = [[{(card.data >| 0) && <div></div>}]]
  },
  {
    name     = "vue auto close tag" ,
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 4,
    key      = [[>]],
    before   = [[<Img|]],
    after    = [[<Img>|</Img>]]
  },
  {
    name     = "vue not close on script",
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 12,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string>| ]]
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
local autotag = require('nvim-ts-autotag')
autotag.test = true
autotag.enableRename = false

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
        vim.fn.cursor(line, p_before-1)
        -- autotag.closeTag()
        helpers.insert(value.key)
        local result = vim.fn.getline(line)
        local pos = vim.fn.getpos('.')
        eq(after, result , "\n\n [ERROR TEXT]: " .. value.name .. "\n")
        eq(p_after, pos[3] + 1, "\n\n [ERROR POS]: " .. value.name .. "\n")
      else
        eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
      end
    end)
  end
end

describe('[close tag]', function()
  Test(run_data)
end)
