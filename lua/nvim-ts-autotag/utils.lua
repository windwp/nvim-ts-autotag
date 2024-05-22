local log = require("nvim-ts-autotag._log")
local get_node_text = vim.treesitter.get_node_text
local M = {}

M.get_node_text = function(node)
    local _, txt = pcall(get_node_text, node, vim.api.nvim_get_current_buf())
    return vim.split(txt, "\n") or {}
end

-- Stolen from nvim `0.10.0` for `0.9.5` users
--- Checks if a list-like table (integer keys without gaps) contains `value`.
---
---
---@param t table Table to check (must be list-like, not validated)
---@param value any Value to compare
---@return boolean `true` if `t` contains `value`
M.list_contains = function(t, value)
    vim.validate({ t = { t, "t" } })
    --- @cast t table<any,any>

    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

M.verify_node = function(node, node_tag)
    local txt = get_node_text(node, vim.api.nvim_get_current_buf())
    if txt:match(string.format("^<%s>", node_tag)) and txt:match(string.format("</%s>$", node_tag)) then
        return true
    end
    return false
end
M.get_cursor = function(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(bufnr or 0))
    return row - 1, col
end

-- Credit to `nvim-treesitter`, where this was adapted from
--- Get the root of the given tree for a given row & column position
---@param row integer 0-indexed row position
---@param col integer 0-indexec column position
---@param root_lang_tree vim.treesitter.LanguageTree
M.get_root_for_position = function(row, col, root_lang_tree)
    local lang_tree = root_lang_tree:language_for_range({ row, col, row, col })

    for _, tree in pairs(lang_tree:trees()) do
        local root = tree:root()
        if root and vim.treesitter.is_in_node_range(root, row, col) then
            return root, tree, lang_tree
        end
    end

    return nil, nil, lang_tree
end

-- Credit to `nvim-treesitter`, where this was adapted from
--- Get the current TSNode at the cursor
---@param winnr integer?
---@return TSNode?
M.get_node_at_cursor = function(winnr)
    winnr = winnr or 0
    local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
    row = row - 1
    local buf = vim.api.nvim_win_get_buf(winnr)
    local ok, root_lang_tree = pcall(vim.treesitter.get_parser, buf)
    if not ok then
        return
    end

    local root = M.get_root_for_position(row, col, root_lang_tree)
    if not root then
        return
    end

    return root:named_descendant_for_range(row, col, row, col)
end

M.dump_node = function(node)
    local text = M.get_node_text(node)
    for _, txt in pairs(text) do
        log.debug(txt)
    end
end

M.is_close_empty_node = function(node)
    local tag_name = ""
    if node ~= nil then
        local text = M.get_node_text(node)
        tag_name = text[#text - 1]
    end
    return tag_name:match("%<%/%>$")
end

M.dump_node_text = function(target)
    log.debug("=============================")
    for node in target:iter_children() do
        local node_type = node:type()
        local text = M.get_node_text(node)
        log.debug("type:" .. node_type .. " ")
        log.debug(text)
    end
    log.debug("=============================")
end
return M
