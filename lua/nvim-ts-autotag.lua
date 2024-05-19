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
    vim.cmd([[augroup nvim_ts_xmltag]])
    vim.cmd([[autocmd!]])
    vim.cmd([[autocmd FileType * call v:lua.require('nvim-ts-autotag.internal').attach()]])
    vim.cmd([[autocmd BufDelete * lua require('nvim-ts-autotag.internal').detach(vim.fn.expand('<abuf>'))]])
    vim.cmd([[augroup end]])
end

return M
