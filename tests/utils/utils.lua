local path_utils = require("tests.utils.paths")
local M = {}

M.paths = path_utils

--- Register the main plugin (`nvim-ts-autotag`) on the runtimepath if it hasn't already been
--- registered
M.rtp_register_ts_autotag = function()
    if not vim.list_contains(vim.opt.runtimepath, path_utils.static.ts_autotag_dir()) then
        vim.opt.runtimepath:append(path_utils.static.ts_autotag_dir())
    end
end

return M
