local ts = require 'nvim-treesitter.configs'
local helpers = {}
ts.setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
  indent = {
    enable = false
  }
}
local eq = assert.are.same

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
    name     = "html auto close tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[>]],
    before   = [[<div| ]],
    after    = [[<div> </div>]]
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
    name     = "typescriptreact auto close tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[>]],
    before   = [[<Img| ]],
    after    = [[<Img>| </Img>]]
  },
  {
    name     = "typescriptreact not close on script" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 6,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string> ]]
  },
  {
    name     = "vue auto close tag" ,
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 4,
    key      = [[>]],
    before   = [[<Img| ]],
    after    = [[<Img>| </Img>]]
  },
  {
    name     = "vue not close on script",
    filepath = './sample/index.vue',
    filetype = "vue",
    linenr   = 12,
    key      = [[>]],
    before   = [[const data:Array<string| ]],
    after    = [[const data:Array<string> ]]
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
autotag.test=true

local function Test(test_data)
  for _, value in pairs(test_data) do
    it("test "..value.name, function()
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '%|')
      local line =value.linenr
      vim.bo.filetype = value.filetype
      if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
        vim.cmd(":e " .. value.filepath)
        vim.fn.setline(line , before)
        vim.fn.cursor(line, p_before)
        helpers.insert(value.key)
        helpers.feed("<esc>")
        local result = vim.fn.getline(line)
        eq(after, result , "\n\n text error: " .. value.name .. "\n")
        vim.cmd(":bd!")
      else
        eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
      end
    end)
  end
end

describe('autotag ', function()
  Test(run_data)
end)
