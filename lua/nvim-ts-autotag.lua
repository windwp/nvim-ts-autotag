local internal = require("nvim-ts-autotag.internal")

local M = {}

---@deprecated
---Will be removed in 1.0.0
function M.init()
    local _, nvim_ts = pcall(require, "nvim-treesitter")
    if not nvim_ts then
        return
    end
    if nvim_ts.define_modules == nil then
        return
    end
    nvim_ts.define_modules({
        autotag = {
            attach = function(bufnr, _)
                vim.deprecate(
                    "Nvim Treesitter Setup",
                    "`require('nvim-ts-autotag').setup()`",
                    "1.0.0",
                    "nvim-ts-autotag",
                    true
                )
                internal.attach(bufnr)
            end,
            detach = function(bufnr)
                internal.detach(bufnr)
            end,
            is_supported = function(lang)
                return internal.is_supported(lang)
            end,
        },
    })
end

M.setup = require("nvim-ts-autotag.config.plugin").setup

return M
