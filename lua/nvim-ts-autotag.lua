local internal = require("nvim-ts-autotag.internal")

local M = {}

function M.init()
  require "nvim-treesitter".define_modules {
    autotag = {
      module_path = 'nvim-ts-autotag.internal',
      is_supported = function(lang)
        return internal.is_supported(lang)
      end
    }
  }
end

function M.setup(opts)
  internal.setup(opts)
  vim.cmd[[augroup nvim_ts_xmltag]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType * call v:lua.require('nvim-ts-autotag.internal').attach()]]
  vim.cmd[[autocmd BufDelete * lua require('nvim-ts-autotag.internal').detach(vim.fn.expand('<abuf>'))]]
  vim.cmd[[augroup end]]
end

return M
