local test_utils = require("tests.utils.utils")

-- Some helpers depend on utilities from the main plugin, so we have to register the plugin on the
-- path if it isn't already present
test_utils.rtp_register_ts_autotag()

local utils = require("nvim-ts-autotag.utils")
local log = require("nvim-ts-autotag._log")

local M = {}

local helpers = {}

function helpers.feed(text, feed_opts, is_replace)
    feed_opts = feed_opts or "n"
    if not is_replace then
        text = vim.api.nvim_replace_termcodes(text, true, false, true)
    end
    vim.api.nvim_feedkeys(text, feed_opts, true)
end

function helpers.insert(text, is_replace)
    helpers.feed("i" .. text, "x", is_replace)
end

M.insert_char = function(text)
    vim.api.nvim_put({ text }, "c", true, true)
end

M.feed = function(text, num)
    local result = ""
    for _ = 1, num, 1 do
        result = result .. text
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(result, true, false, true), "x", true)
end

M.Test_filter = function(data)
    local run_data = {}
    for _, value in pairs(data) do
        if value.only == true then
            table.insert(run_data, value)
            break
        end
    end
    if #run_data == 0 then
        run_data = data
    end
    return run_data
end

local compare_text = function(linenr, text_after, name, cursor_add, end_cursor)
    cursor_add = cursor_add or 0
    local new_text = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr + #text_after - 1, true)
    for i = 1, #text_after, 1 do
        local t = string.gsub(text_after[i], "%|", "")
        if t and new_text[i] and t:gsub("%s+$", "") ~= new_text[i]:gsub("%s+$", "") then
            assert.are.same(t, new_text[i], "\n\n text error: " .. name .. "\n")
        end
        local p_after = string.find(text_after[i], "%|")
        if p_after then
            local row, col = utils.get_cursor()
            if end_cursor then
                assert.are.same(row, linenr + i - 2, "\n\n cursor row error: " .. name .. "\n")
                assert.are.same(col + 1, end_cursor, "\n\n end cursor column error : " .. name .. "\n")
            else
                assert.are.same(row, linenr + i - 2, "\n\n cursor row error: " .. name .. "\n")
                p_after = p_after + cursor_add
                assert.are.same(col, math.max(p_after - 2, 0), "\n\n cursor column error : " .. name .. "\n")
            end
        end
    end
    return true
end
local islist = vim.islist or vim.tbl_islist
M.Test_withfile = function(test_data, cb)
    for _, value in pairs(test_data) do
        it("test " .. value.name, function()
            local text_before = {}
            value.linenr = value.linenr or 1
            local pos_before = {
                linenr = value.linenr,
                colnr = 0,
            }
            if not islist(value.before) then
                value.before = { value.before }
            end
            for index, text in pairs(value.before) do
                local txt = string.gsub(text, "%|", "")
                table.insert(text_before, txt)
                if string.match(text, "%|") then
                    if string.find(text, "%|") then
                        pos_before.colnr = string.find(text, "%|")
                        pos_before.linenr = value.linenr + index - 1
                    end
                end
            end
            if not islist(value.after) then
                value.after = { value.after }
            end
            vim.bo.filetype = value.filetype or "text"
            vim.cmd(":bd!")
            if cb.before_each then
                cb.before_each(value)
            end
            if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
                vim.cmd(":e " .. value.filepath)
                if value.filetype then
                    vim.bo.filetype = value.filetype
                end
                vim.cmd(":e")
            else
                vim.cmd(":new")
                if value.filetype then
                    vim.bo.filetype = value.filetype
                end
            end
            vim.api.nvim_buf_set_lines(0, value.linenr - 1, value.linenr + #text_before, false, text_before)
            vim.api.nvim_win_set_cursor(0, { pos_before.linenr, pos_before.colnr - 1 })
            log.debug("insert:" .. value.key)

            if type(value.key) == "string" then
                if cb.mode == "i" then
                    helpers.insert(value.key, value.not_replace_term_code)
                else
                    helpers.feed(value.key, "x")
                end
            else
                for _, key in pairs(value.key) do
                    helpers.feed(key, "x")
                    vim.wait(1)
                end
            end
            vim.wait(2)
            helpers.feed("<esc>")
            compare_text(value.linenr, value.after, value.name, cb.cursor_add, value.end_cursor)
            if cb.after_each then
                cb.after_each(value)
            end
            vim.cmd(":bd!")
        end)
    end
end

M.dump_node = function(node)
    local text = utils.get_node_text(node)
    for _, txt in pairs(text) do
        log.debug(txt)
    end
end

M.dump_node_text = function(target)
    for node in target:iter_children() do
        local node_type = node:type()
        local text = utils.get_node_text(node)
        log.debug("type:" .. node_type .. " ")
        log.debug(text)
    end
end
return M
