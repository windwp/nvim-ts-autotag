local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local log = require('nvim-ts-autotag._log')
local get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text or ts_utils.get_node_text
local M = {}

M.get_node_text = function(node)
    local _, txt = pcall(get_node_text, node, vim.api.nvim_get_current_buf())
    return vim.split(txt, '\n') or {}
end

M.verify_node = function(node, node_tag)
    local txt = get_node_text(node, vim.api.nvim_get_current_buf())
    if
        txt:match(string.format('^<%s>', node_tag))
        and txt:match(string.format('</%s>$', node_tag))
    then
        return true
    end
    return false
end
M.get_cursor = function(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(bufnr or 0))
    return row - 1, col
end
M.dump_node = function(node)
    local text = M.get_node_text(node)
    for _, txt in pairs(text) do
        log.debug(txt)
    end
end

M.is_close_empty_node = function(node)
    local tag_name = ''
    if node ~= nil then
        local text = M.get_node_text(node)
        tag_name = text[#text - 1]
    end
    return tag_name:match('%<%/%>$')
end

M.dump_node_text = function(target)
    log.debug('=============================')
    for node in target:iter_children() do
        local node_type = node:type()
        local text = M.get_node_text(node)
        log.debug('type:' .. node_type .. ' ')
        log.debug(text)
    end
    log.debug('=============================')
end
return M
