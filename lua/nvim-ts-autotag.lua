local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

local M = {}

M.tbl_filetypes = {
  'html', 'xml', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'php'
}

M.tbl_skipTag = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
}

M.test = false

M.setup = function (opts)
  opts            = opts or {}
  M.tbl_filetypes = opts.filetypes or M.tbl_filetypes
  M.tbl_skipTag   = opts.skip_tag or M.tbl_skipTag
  vim.cmd[[augroup nvim_ts_xmltag]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType * call v:lua.require('nvim-ts-autotag').on_file_type()]]
  vim.cmd[[augroup end]]
end


local function is_in_table(tbl, val)
  for _, value in pairs(tbl) do
    if string.match(val, value) then return true end
  end
  return false
end

local function isJsX()
  if is_in_table({'typescriptreact', 'javascriptreact'}, vim.bo.filetype) then
    return true
  end
  return false
end
M.on_file_type = function ()
  if is_in_table(M.tbl_filetypes,vim.bo.filetype) then
    vim.cmd[[inoremap <silent> <buffer> > ><c-o>:lua require('nvim-ts-autotag').closeTag()<CR>]]
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("augroup nvim_ts_xmltag_" .. bufnr)
    vim.cmd[[autocmd!]]
    vim.cmd[[autocmd InsertLeave <buffer> call v:lua.require('nvim-ts-autotag').renameTag() ]]
    vim.cmd[[augroup end]]
  end
end
local function find_child_match(target, pattern)
  for node in target:iter_children() do
    local node_type = node:type()
    if node_type ~= nil and node_type == pattern then
      return node
    end
  end
end

local function find_parent_match(target, pattern,max_depth)
  max_depth = max_depth or 20
  local cur_depth = 0
  local cur_node = target
  while cur_node ~= nil do
    local node_type = cur_node:type()
    if node_type ~= nil and node_type== pattern then
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

local function find_tag_node(start_tag_pattern, name_tag_pattern)
  local cur_node = ts_utils.get_node_at_cursor()
  local start_tag_node = find_parent_match(cur_node, start_tag_pattern)
  if(M.test and start_tag_node == nil) then
   start_tag_node = find_child_match(cur_node, start_tag_pattern)
  end
  if start_tag_node== nil then return nil end
  local tbl_name_pattern = vim.split(name_tag_pattern, '>')
  local name_node = start_tag_node
  for _, pattern in pairs(tbl_name_pattern) do
    name_node = find_child_match(name_node, pattern)
  end
  return name_node
end

local function find_close_tag_node(close_tag_pattern, name_tag_pattern, cur_node)
  cur_node = cur_node or ts_utils.get_node_at_cursor()
  local close_tag_node = find_child_match(cur_node, close_tag_pattern)
  if close_tag_node== nil then return nil end
  local tbl_name_pattern = vim.split(name_tag_pattern, '>')
  local name_node = close_tag_node
  for _, pattern in pairs(tbl_name_pattern) do
    name_node = find_child_match(name_node, pattern)
  end
  return name_node
end


M.closeTag = function ()
  local start_tag_pattern = 'start_tag'
  local name_tag_pattern = 'tag_name'
  if isJsX() then
    start_tag_pattern = 'jsx_element'
    name_tag_pattern = 'jsx_opening_element>identifier'
  end
  local tag_node = find_tag_node(start_tag_pattern, name_tag_pattern)
  local tag_name = get_tag_name(tag_node)
  if tag_name ~= nil and not is_in_table(M.tbl_skipTag,tag_name) then
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
  local start_tag_pattern      = 'start_tag'
  local start_name_tag_pattern = 'tag_name'
  local close_tag_pattern      = 'erroneous_end_tag'
  local close_name_tag_pattern = 'erroneous_end_tag_name'
  local element_tag            = 'element'
  if isJsX() then
    start_tag_pattern = 'jsx_opening_element'
    start_name_tag_pattern = 'identifier'
    close_tag_pattern = 'jsx_closing_element'
    close_name_tag_pattern = 'identifier'
    element_tag            = 'jsx_element'
  end
  local tag_node = find_tag_node(start_tag_pattern, start_name_tag_pattern)
  if tag_node == nil then return end
  local tag_name = get_tag_name(tag_node)
  tag_node = find_parent_match(tag_node, element_tag, 2)
  if tag_node == nil then return end
  local close_tag_node = find_close_tag_node(close_tag_pattern, close_name_tag_pattern, tag_node)
  if close_tag_node ~= nil then
    local close_tag_name = get_tag_name(close_tag_node)
    if tag_name ~=close_tag_name then
      replaceTextNode(close_tag_node, tag_name)
    end
  else
    close_tag_node = find_child_match(tag_node,'ERROR')
    if close_tag_node ~=nil then
      local close_tag_name = get_tag_name(close_tag_node)
      if close_tag_name=='</>' then
        replaceTextNode(close_tag_node, "</"..tag_name..">")
      end
    end
  end
end

local function checkEndTag()
  local end_tag_pattern = 'erroneous_end_tag'
  local end_name_tag_pattern = 'erroneous_end_tag_name'
  local start_tag_pattern = 'start_tag'
  local start_name_tag_pattern = 'tag_name'
  local element_tag            = 'element'
  if isJsX() then
     end_tag_pattern = 'jsx_closing_element'
     end_name_tag_pattern = 'identifier'
     start_tag_pattern = 'jsx_opening_element'
     start_name_tag_pattern = 'identifier'
    element_tag            = 'jsx_element'
  end
  local tag_node = find_tag_node(end_tag_pattern, end_name_tag_pattern)
  if tag_node == nil then return end
  local tag_name = get_tag_name(tag_node)
  tag_node = find_parent_match(tag_node, element_tag, 2)
  if tag_node == nil then return end
  local start_tag_node = find_close_tag_node(start_tag_pattern, start_name_tag_pattern, tag_node)
  if start_tag_node ~= nil then
    local start_tag_name = get_tag_name(start_tag_node)
    if tag_name ~=start_tag_name then
      replaceTextNode(start_tag_node, tag_name)
    end
  end
end
M.renameTag = function ()
  checkStartTag()
  checkEndTag()
end
return M
