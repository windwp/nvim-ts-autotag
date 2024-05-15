local internal = require("nvim-ts-autotag.internal")

local M = {}

---@deprecated
---Will be removed in 1.0.0
function M.init()
    local _, nvim_ts = pcall(require, "nvim-treesitter")
    if not nvim_ts then
        return
    end
    nvim_ts.define_modules({
        autotag = {
            attach = function(bufnr, lang)
                vim.deprecate(
                    "Nvim Treesitter Setup",
                    "`require('nvim-ts-autotag').setup()`",
                    "1.0.0",
                    "nvim-ts-autotag",
                    true
                )
                internal.attach(bufnr, lang)
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
end

function M.setup(opts)
    internal.setup(opts)
    local augroup = vim.api.nvim_create_augroup("nvim_ts_xmltag", { clear = true })
    vim.api.nvim_create_autocmd("Filetype", {
        group = augroup,
        callback = function(args)
            require("nvim-ts-autotag.internal").attach(args.buf)
        end,
    })
    vim.api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        callback = function(args)
            require("nvim-ts-autotag.internal").detach(args.buf)
        end,
    })
end

return M
