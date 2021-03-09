local ts = require 'nvim-treesitter.configs'
local helpers = {}
ts.setup {
  ensure_installed = 'maintained',
  highlight = {
    use_languagetree = true,
    enable = true
  },
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
    name     = "html rename tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<di|v> dsadsa </div> ]],
    after    = [[<lala|> dsadsa </lala> ]]
  },
  {
    name     = "html rename tag with attr" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<di|v class="lla"> dsadsa </div> ]],
    after    = [[<lala| class="lla"> dsadsa </lala|> ]]
  },
  {
    name     = "html rename on close tag with attr" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<div class="lla"> dsadsa </di|v> ]],
    after    = [[<lala class="lla"> dsadsa </lala|> ]]
  },
  {
    name     = "typescriptreact rename tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<di|v> dsadsa </div> ]],
    after    = [[<lala|> dsadsa </lala> ]]
  },
  {
    name     = "typescriptreact rename tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<di|v class="lla"> dsadsa </div> ]],
    after    = [[<lala| class="lla"> dsadsa </lala> ]]
  },
  {
    name     = "typescriptreact rename on close tag with attr" ,
    filepath = './sample/index.tsx',
    filetype = "html",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<div class="lla"> dsadsa </di|v> ]],
    after    = [[<lala class="lla"> dsadsa </lala|> ]]
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
        vim.cmd(":bd!")
        vim.cmd(":e " .. value.filepath)
        vim.fn.setline(line , before)
        vim.fn.cursor(line, p_before)
        -- autotag.closeTag()
        helpers.feed(value.key,'x')
        helpers.feed("<esc>",'x')
        local result = vim.fn.getline(line)
        eq(after, result , "\n\n text error: " .. value.name .. "\n")
      else
        eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
      end
    end)
  end
end

describe('[rename tag]', function()
  Test(run_data)
end)

