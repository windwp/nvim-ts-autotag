local M = {}

---Search up from the current file until we find the full path of the base `tests/` directory and
---return it
---@param test_file string Filename to look for in each directory, if it exists then stop the search
---@return fun(): string dir A function wrapping the found directory
local function search_dir_up(test_file)
    -- This is the path of the directory of the current file
    local cur_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
    local uv = vim.uv or vim.loop
    ---@diagnostic disable-next-line: param-type-mismatch
    while not uv.fs_stat(cur_dir .. "/" .. test_file, nil) and cur_dir ~= "/" do
        cur_dir = vim.fn.fnamemodify(cur_dir, ":h")
    end
    if cur_dir == "/" then
        error("Failed to locate the base 'tests/' directory!")
    end
    -- We return a wrapping function instead of a bare string so its easier to enforce "readonly"
    -- uses of the searched directory
    return function()
        return cur_dir
    end
end

--- WARN: DO NOT MUTATE THESE VALUES!
---
--- Table containing useful paths to directories within the plugin
M.static = {
    --- Full path of the `tests/` directory
    tests_dir = search_dir_up("test.lua"),
    --- Full base path of the plugin where the `.git` directory resides
    ts_autotag_dir = search_dir_up(".git"),
}

---@class nvim-ts-autotag.Root
---@field package path string
local Root = {
    path = M.static.tests_dir(),
}

---@package
---@nodiscard
---@return nvim-ts-autotag.Root
function Root:new(o)
    o = o or {}

    setmetatable(o, self)
    -- The last part of the path must be a "/" to work correctly
    if self.path:sub(#self.path, #self.path) ~= "/" then
        self.path = self.path .. "/"
    end
    self.__index = self
    return o
end

--- Create a new instance, pushing the given path onto it
---@nodiscard
---@param path string The new path to add
---@return nvim-ts-autotag.Root
function Root:push(path)
    local new_root = self:new()
    -- Since we're extending the path, the current path must be a directory, ensure it ends in a "/"
    if new_root.path:sub(#new_root.path) ~= "/" then
        new_root.path = new_root.path .. "/"
    end
    new_root.path = new_root.path .. path
    return new_root
end

--- Get the current path string
---@return string path
function Root:get()
    return self.path
end

M.Root = Root:new()

return M
