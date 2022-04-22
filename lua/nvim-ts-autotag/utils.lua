local log = require('nvim-ts-autotag._log')
local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local get_node_text = vim.treesitter.query.get_node_text or ts_utils.get_node_text
local M = {}

M.get_node_text = function(...)
    local txt = get_node_text(...)
    return vim.split(txt, '\n')
end

M.dump_node = function(node)
    local text = M.get_node_text(node)
    for _, txt in pairs(text) do
        print(txt)
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
