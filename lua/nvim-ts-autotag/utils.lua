local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local M={}

M.dump_node = function(node)
    local text=ts_utils.get_node_text(node)
    for _, txt in pairs(text) do
        print(txt)
    end
end

M.is_close_empty_node = function(node)
    local tag_name = ''
    if node ~= nil then
        local text = ts_utils.get_node_text(node)
        tag_name = text[#text-1]
    end
    return tag_name:match("%<%/%>$")
end

return M
