local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local configs = require'nvim-treesitter.configs'

local M = {}

M.tbl_filetypes = {
  'html', 'xml', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
}

M.tbl_skipTag = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
}


local HTML_TAG = {
  start_tag_pattern      = 'start_tag',
  start_name_tag_pattern = 'tag_name',
  end_tag_pattern        = "end_tag",
  end_name_tag_pattern   = "tag_name",
  close_tag_pattern      = 'erroneous_end_tag',
  close_name_tag_pattern = 'erroneous_end_tag_name',
  element_tag            = 'element',
  skip_tag_pattern       = {'quoted_attribute_value', 'end_tag'},
}

local JSX_TAG = {
  start_tag_pattern       = 'jsx_opening_element',
  start_name_tag_pattern  = 'identifier',
  end_tag_pattern         = "jsx_closing_element",
  end_name_tag_pattern    = "identifier",
  close_tag_pattern       = 'jsx_closing_element',
  close_name_tag_pattern  = 'identifier',
  element_tag             = 'jsx_element',
  skip_tag_pattern        = {'jsx_closing_element','jsx_expression', 'string', 'jsx_attribute'},
}


M.enableRename = true
M.enableClose  = true

M.setup = function (opts)
  opts            = opts or {}
  M.tbl_filetypes = opts.filetypes or M.tbl_filetypes
  M.tbl_skipTag   = opts.skip_tag or M.tbl_skipTag
end

local function is_in_table(tbl, val)
  if tbl == nil then return false end
  for _, value in pairs(tbl) do
    if val== value then return true end
  end
  return false
end

M.is_supported=function (lang)
  return is_in_table(M.tbl_filetypes,lang)
end

local function is_jsx()
  if is_in_table({'typescriptreact', 'javascriptreact'}, vim.bo.filetype) then
    return true
  end
  return false
end

local function  get_ts_tag()
  local ts_tag = HTML_TAG
  if(is_jsx()) then ts_tag = JSX_TAG end
  return ts_tag
end

M.on_file_type = function ()
end
local function find_child_match(opts)
  local target           = opts.target
  local pattern          = opts.pattern
  local skip_tag_pattern = opts.skip_tag_pattern
  assert(target ~= nil, "find child target not nil :" .. pattern)
  for node in target:iter_children() do
    local node_type = node:type()
    if node_type ~= nil and
      node_type == pattern and
      not is_in_table(skip_tag_pattern, node_type)
    then
      return node
    end
  end
end

local function find_parent_match(opts)
  local target           = opts.target
  local max_depth        = opts.max_depth or 10
  local pattern          = opts.pattern
  local skip_tag_pattern = opts.skip_tag_pattern
  assert(target ~= nil, "find parent target not nil :" .. pattern)
  local cur_depth = 0
  local cur_node = target
  while cur_node ~= nil do
    local node_type = cur_node:type()
    if is_in_table(skip_tag_pattern,node_type) then return nil end
    if node_type ~= nil and node_type == pattern then
      return cur_node
    elseif cur_depth < max_depth then
      cur_depth = cur_depth + 1
      cur_node = cur_node:parent()
    else
      return nil
    end
  end
  return nil end

local function get_tag_name(node)
  local tag_name = nil
  if node ~=nil then
    tag_name = ts_utils.get_node_text(node)[1]
  end
  return tag_name
end

local function find_tag_node(opt)
  local target           = opt.target or ts_utils.get_node_at_cursor()
  local tag_pattern      = opt.tag_pattern
  local name_tag_pattern = opt.name_tag_pattern
  local skip_tag_pattern = opt.skip_tag_pattern
  local find_child        = opt.find_child or false
  local node
  if find_child then
     node              = find_child_match({
      target           = target,
      pattern          = tag_pattern,
      skip_tag_pattern = skip_tag_pattern
    })
  else
     node              = find_parent_match({
      target           = target,
      pattern          = tag_pattern,
      skip_tag_pattern = skip_tag_pattern
    })
  end
  if node == nil then return nil end
  local tbl_name_pattern = vim.split(name_tag_pattern, '>')
  local name_node = node
  for _, pattern in pairs(tbl_name_pattern) do
    name_node = find_child_match({
      target = name_node,
      pattern = pattern
    })
  end
  return name_node
end

local function find_close_tag_node(opt)
  opt.find_child=true
  return find_tag_node(opt)
end


local function  checkCloseTag()
  local ts_tag = get_ts_tag()
  local tag_node     = find_tag_node({
    tag_pattern      = ts_tag.start_tag_pattern,
    name_tag_pattern = ts_tag.start_name_tag_pattern,
    skip_tag_pattern = ts_tag.skip_tag_pattern
  })
  if tag_node ~=nil then
    local tag_name = get_tag_name(tag_node)
    if tag_name ~= nil and  is_in_table(M.tbl_skipTag, tag_name) then
      return false
    end
    return true,tag_name
  end
  return false
end
M.closeTag = function ()
   local result, tag_name = checkCloseTag()
   if result == true and tag_name ~= nil then
     vim.cmd(string.format([[normal! a</%s>]],tag_name))
     vim.cmd[[normal! T>]]
   end
end

local function replaceTextNode(node, tag_name)
  if node == nil then return end
  local start_row, start_col, end_row, end_col = node:range()
  if start_row == end_row then
    local line = vim.fn.getline(start_row + 1)
    local newline = line:sub(0, start_col) .. tag_name .. line:sub(end_col + 1, string.len(line))
    vim.fn.setline(start_row + 1,{newline})
  end
end

local function checkStartTag()
  local ts_tag = HTML_TAG
  if(is_jsx()) then ts_tag = JSX_TAG end
  local tag_node = find_tag_node({
    tag_pattern = ts_tag.start_tag_pattern,
    name_tag_pattern = ts_tag.start_name_tag_pattern,
  })

  if tag_node == nil then return end
  local tag_name = get_tag_name(tag_node)
  tag_node = find_parent_match({
    target = tag_node,
    pattern = ts_tag.element_tag,
    max_depth = 2
  })
  if tag_node == nil then return end
  local close_tag_node = find_close_tag_node({
    target             = tag_node,
    tag_pattern        = ts_tag.close_tag_pattern,
    name_tag_pattern   = ts_tag.close_name_tag_pattern,
  })
  if close_tag_node ~= nil then
    local close_tag_name = get_tag_name(close_tag_node)
    if tag_name ~=close_tag_name then
      replaceTextNode(close_tag_node, tag_name)
    end
  else
    close_tag_node = find_child_match({
      target = tag_node,
      pattern = 'ERROR'
    })
    if close_tag_node ~=nil then
      local close_tag_name = get_tag_name(close_tag_node)
      if close_tag_name=='</>' then
        replaceTextNode(close_tag_node, "</"..tag_name..">")
      end
    end
  end
end

local function checkEndTag()
  local ts_tag = get_ts_tag()
  local tag_node = find_tag_node({
    tag_pattern = ts_tag.close_tag_pattern,
    name_tag_pattern = ts_tag.close_name_tag_pattern,
  })

  if tag_node == nil then return end
  local tag_name = get_tag_name(tag_node)
  tag_node    = find_parent_match({
    target    = tag_node,
    pattern   = ts_tag.element_tag,
    max_depth = 2
  })
  if tag_node == nil then return end
  local start_tag_node = find_close_tag_node({
    target             = tag_node,
    tag_pattern        = ts_tag.start_tag_pattern,
    name_tag_pattern   = ts_tag.start_name_tag_pattern,
  })
  if start_tag_node ~= nil then
    local start_tag_name = get_tag_name(start_tag_node)
    if tag_name ~= start_tag_name then
      replaceTextNode(start_tag_node, tag_name)
    end
  end
end

M.renameTag = function ()
  checkStartTag()
  checkEndTag()
end

M.attach = function (bufnr, lang)
 local config = configs.get_module('autotag')
 M.setup(config)
 if is_in_table(M.tbl_filetypes,vim.bo.filetype) then
   vim.cmd[[inoremap <silent> <buffer> > ><c-o>:lua require('nvim-ts-autotag.internal').closeTag()<CR>]]
   bufnr = bufnr or vim.api.nvim_get_current_buf()
   if M.enableRename == true then
     vim.cmd("augroup nvim_ts_xmltag_" .. bufnr)
     vim.cmd[[autocmd!]]
     vim.cmd[[autocmd InsertLeave <buffer> call v:lua.require('nvim-ts-autotag.internal').renameTag() ]]
     vim.cmd[[augroup end]]
   end
 end
end

M.detach = function (bufnr )

end

-- _G.AUTO = M
return M
