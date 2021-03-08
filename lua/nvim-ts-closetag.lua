local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

local M= {}
M.tbl_filetypes = {
  'html', 'xml', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
}
M.tbl_skipTag = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
}

M.setup = function (opts)
  opts            = opts or {}
  M.tbl_filetypes = opts.filetypes or M.tbl_filetypes
  M.tbl_skipTag   = opts.skip_tag or M.tbl_skipTag
  vim.cmd(string.format([[
    autocmd FileType %s inoremap <silent> <buffer> > ><c-o>:lua require('nvim-ts-closetag').closeTag()<cr>
    ]],table.concat(M.tbl_filetypes,',')))
end

local function is_in_table(tbl, val)
  for _, value in pairs(tbl) do
    if string.match(val, value) then return true end
  end
  return false
end

local function find_child_match(target, pattern)
  for node in target:iter_children() do
    local node_type = node:type()
    if node_type ~=nil and string.match(node_type,pattern) then
      return node
    end
  end
end

local function find_parent_match(target, pattern)
  local cur_node = target
  while cur_node ~= nil do
    local node_type = cur_node:type()
    if node_type ~= nil and string.match(node_type, pattern) then
      return cur_node
    else
      cur_node = cur_node:parent()
    end
  end
end

local function find_tag_name(start_tag_pattern, name_tag_pattern)
    local cur_node = ts_utils.get_node_at_cursor()
    local start_tag_node = find_parent_match(cur_node,start_tag_pattern)
    if start_tag_node== nil then return nil end
    local tag_name = nil
    local tbl_name_pattern = vim.split(name_tag_pattern, '>')
    local name_node = start_tag_node
    for _, pattern in pairs(tbl_name_pattern) do
       name_node = find_child_match(name_node, pattern)
    end
    if name_node ~=nil then
      tag_name = ts_utils.get_node_text(name_node)[1]
    end
    return tag_name
end

M.closeTag = function ()
  if is_in_table(M.tbl_filetypes,vim.bo.filetype) then
    local start_tag_pattern = 'start_tag'
    local name_tag_pattern = 'tag_name'
    if is_in_table({'typescriptreact', 'javascriptreact'}, vim.bo.filetype) then
      start_tag_pattern = 'jsx_element'
      name_tag_pattern = 'jsx_opening_element>identifier'
    end
    local tag_name = find_tag_name(start_tag_pattern, name_tag_pattern)
    if tag_name ~= nil and not is_in_table(M.tbl_skipTag,tag_name) then
      vim.cmd(string.format([[normal! a</%s>]],tag_name))
      vim.cmd[[normal! T>]]
    end
  end
end
return M
