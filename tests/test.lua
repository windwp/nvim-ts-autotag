-- Ensure our test lua files are in `package.path`
local fdir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = fdir .. "/?.lua;" .. package.path

require("tests.minimal_init")

---@type string
local test_file = vim.v.argv[#vim.v.argv]
if test_file == "" or not test_file:find("tests/specs/", nil, true) then
    test_file = "tests/specs"
end
print("[STARTUP] Running all tests in " .. test_file)

require("plenary.test_harness").test_directory(test_file, {
    minimal_init = "tests/minimal_init.lua",
    sequential = true,
})
