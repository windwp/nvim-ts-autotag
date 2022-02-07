local ts = require 'nvim-treesitter.configs'
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.rescript = {
  install_info = {
    url = "https://github.com/nkrkv/nvim-treesitter-rescript",
    files = {"src/parser.c", "src/scanner.c"},
    branch = "main",
  },
  maintainers = { "@nkrkv" },
  filetype = "rescript",
}

local log=require('nvim-ts-autotag._log')

if not _G.test_rename then
  return
end

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
    name     = "html rename open tag" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<di|v> dsadsa </div> ]],
    after    = [[<lala|> dsadsa </lala> ]]
  },
  {
    name     = "html rename open tag with attr" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<di|v class="lla"> dsadsa </div> ]],
    after    = [[<lala| class="lla"> dsadsa </lala|> ]]
  },
  {
    name     = "html rename close tag with attr" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[ciwlala]],
    before   = [[<div class="lla"> dsadsa </di|v> ]],
    after    = [[<lala class="lla"> dsadsa </lala|> ]]
  },
  {
    name     = "html not rename close tag on char <" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 10,
    key      = [[i<]],
    before   = [[<div class="lla"> dsadsa |/button> ]],
    after    = [[<div| class="lla"> dsadsa |</button> ]]
  },
  {
    name     = "html not rename close tag with not valid" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = {
      [[<di|v class="lla" ]],
      [[ dsadsa </div>]]
    },
    after    = [[<lala class="lla" ]]
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
    name     = "html not rename close tag with not valid" ,
    filepath = './sample/index.html',
    filetype = "html",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = {
      [[<div class="lla" </d|iv>]],
    },
    after    = [[<div class="lla" </l|ala>]]
  },
  {
    name     = "typescriptreact rename open tag" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<di|v> dsadsa </div> ]],
    after    = [[<lala|> dsadsa </lala> ]]
  },
  {
    name     = "typescriptreact rename open tag with attr" ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<di|v class="lla"> dsadsa </div> ]],
    after    = [[<lala| class="lla"> dsadsa </lala> ]]
  },
  {
    name     = "typescriptreact rename close tag with attr" ,
    filepath = './sample/index.tsx',
    filetype = "html",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<div class="lla"> dsadsa </di|v> ]],
    after    = [[<lala class="lla"> dsadsa </lala|> ]]
  },
  {
    name     = "17 typescriptreact nested indentifer " ,
    filepath = './sample/index.tsx',
    filetype = "typescriptreact",
    linenr   = 12,
    key      = [[ciwlala]],
    before   = [[<Opt.In|put></Opt.Input> ]],
    after    = [[<Opt.lala>|</Opt.lala> ]]
  },
    {
        name     = "18 rename empty node " ,
        filepath = './sample/index.tsx',
        filetype = "typescriptreact",
        linenr   = 12,
        key      = [[ilala]],
        before   = [[<|><div></div></>]],
        after    = [[<|lala><div></div></lala>]]
    },
    {
        name     = "19 rename start tag on svelte " ,
        filepath = './sample/index.svelte',
        filetype = "svelte",
        linenr   = 18,
        key      = [[ciwlala]],
        before   = [[<|data></data>]],
        after    = [[<|lala></lala>]]
    },
    {
        name     = "20 rename end tag on svelte " ,
        filepath = './sample/index.svelte',
        filetype = "svelte",
        linenr   = 18,
        key      = [[ciwlala]],
        before   = [[<data></da|ta>]],
        after    = [[<lala></lala>]]
    },
    {
      name     = "21 rescript rename open tag" ,
      filepath = './sample/index.res',
      filetype = "rescript",
      linenr   = 12,
      key      = [[ciwlala]],
      before   = [[<di|v> dsadsa </div> ]],
      after    = [[<lala|> dsadsa </lala> ]]
    },
    {
      name     = "22 rescript rename open tag with attr" ,
      filepath = './sample/index.res',
      filetype = "rescript",
      linenr   = 12,
      key      = [[ciwlala]],
      before   = [[<di|v class="lla"> dsadsa </div> ]],
      after    = [[<lala| class="lla"> dsadsa </lala> ]]
    },
    {
      name     = "23 rescript rename close tag with attr" ,
      filepath = './sample/index.res',
      filetype = "rescript",
      linenr   = 12,
      key      = [[ciwlala]],
      before   = [[<div class="lla"> dsadsa </di|v> ]],
      after    = [[<lala class="lla"> dsadsa </lala|> ]]
    },
    -- {
    --     only = true,
    --     name     = "18 rename node to empty node " ,
    --     filepath = './sample/index.tsx',
    --     filetype = "typescriptreact",
    --     linenr   = 12,
    --     key      = [[ciw<esc>]],
    --     before   = [[<la|la><div></div></lala>]],
    --     after    = [[<|><div></div></>]]
    -- },

    -- TODO close tag with empty
    -- {
    --     only = true,
    --     name     = "18 rename end empty node " ,
    --     filepath = './sample/index.tsx',
    --     filetype = "typescriptreact",
    --     linenr   = 12,
    --     key      = [[ilala]],
    --     before   = [[<span><> <div></div></|><span>]],
    --     after    = [[<span><|lala><div></div></lala></span>]]
    -- },
    -- {
    --     name     = "19 rename end empty node " ,
    --     filepath = './sample/index.tsx',
    --     filetype = "typescriptreact",
    --     linenr   = 12,
    --     key      = [[ilala]],
    --     before   = [[<><div></div></|>]],
    --     after    = [[<|lala><div></div></lala>]]
    -- }
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
      local text_before={}
      local pos_before={
        linenr = value.linenr,
        colnr=0
      }
      if not vim.tbl_islist(value.before) then
        value.before = {value.before}
      end
      local numlnr = 0
      for _, text in pairs(value.before) do
        local txt = string.gsub(text, '%|' , "")
        table.insert(text_before, txt )
        if string.match( text, "%|") then
          pos_before.colnr = string.find(text, '%|')
          pos_before.linenr = pos_before.linenr + numlnr
        end
        numlnr =  numlnr + 1
      end
      local after = string.gsub(value.after, '%|' , "")
      vim.bo.filetype = value.filetype
      if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
        vim.cmd(":bd!")
        vim.cmd(":e " .. value.filepath)
        local bufnr=vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(bufnr, pos_before.linenr -1, pos_before.linenr +#text_before, false, text_before)
        vim.fn.cursor(pos_before.linenr, pos_before.colnr)
        -- autotag.renameTag()
        helpers.feed(value.key, 'x')
        helpers.feed("<esc>",'x')
        vim.wait(10)
        local result = vim.fn.getline(pos_before.linenr)
        eq(after, result , "\n\n ERROR: " .. value.name .. "\n")
      else
        eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
      end
    end)
  end
end

describe('[rename tag]', function()
    Test(run_data)
end)

