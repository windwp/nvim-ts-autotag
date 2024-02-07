local _, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
local configs = require("nvim-treesitter.configs")
local parsers = require("nvim-treesitter.parsers")
local log = require("nvim-ts-autotag._log")
local utils = require("nvim-ts-autotag.utils")

local M = {}

-- stylua: ignore
M.tbl_filetypes = {
    'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx', 'rescript',
    'xml',
    'php',
    'markdown',
    'astro', 'glimmer', 'handlebars', 'hbs',
    'htmldjango',
    'eruby',
    'templ',
}

-- stylua: ignore
M.tbl_skipTag = {
    'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
    'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr', 'menuitem'
}

-- stylua: ignore
local HTML_TAG = {
    filetypes              = {
        'astro',
        'html',
        'htmldjango',
        'markdown',
        'php',
        'xml',
    },
    start_tag_pattern      = { 'start_tag' },
    start_name_tag_pattern = { 'tag_name' },
    end_tag_pattern        = { 'end_tag' },
    end_name_tag_pattern   = { 'tag_name' },
    close_tag_pattern      = { 'erroneous_end_tag' },
    close_name_tag_pattern = { 'erroneous_end_tag_name' },
    element_tag            = { 'element' },
    skip_tag_pattern       = { 'quoted_attribute_value', 'end_tag' },
}
-- stylua: ignore
local JSX_TAG = {
    filetypes              = {
        'typescriptreact', 'javascriptreact', 'javascript.jsx',
        'typescript.tsx', 'javascript', 'typescript', 'rescript'
    },
    start_tag_pattern      = { 'jsx_opening_element', 'start_tag' },
    start_name_tag_pattern = { 'identifier', 'nested_identifier', 'tag_name', 'member_expression', 'jsx_identifier' },
    end_tag_pattern        = { 'jsx_closing_element', 'end_tag' },
    end_name_tag_pattern   = { 'identifier', 'tag_name' },
    close_tag_pattern      = { 'jsx_closing_element', 'nested_identifier' },
    close_name_tag_pattern = { 'member_expression', 'nested_identifier', 'jsx_identifier', 'identifier', '>' },
    element_tag            = { 'jsx_element', 'element' },
    skip_tag_pattern       = {
        'jsx_closing_element', 'jsx_expression', 'string', 'jsx_attribute', 'end_tag',
        'string_fragment'
    },

}


-- stylua: ignore
local HBS_TAG = {
    filetypes              = { 'glimmer', 'handlebars', 'hbs', 'htmldjango' },
    start_tag_pattern      = { 'element_node_start' },
    start_name_tag_pattern = { 'tag_name' },
    end_tag_pattern        = { 'element_node_end' },
    end_name_tag_pattern   = { 'tag_name' },
    close_tag_pattern      = { 'element_node_end' },
    close_name_tag_pattern = { 'tag_name' },
    element_tag            = { 'element_node' },
    skip_tag_pattern       = { 'element_node_end', 'attribute_node', 'concat_statement' },
}


-- stylua: ignore
local SVELTE_TAG = {
    filetypes              = { 'svelte' },
    start_tag_pattern      = { 'start_tag' },
    start_name_tag_pattern = { 'tag_name' },
    end_tag_pattern        = { 'end_tag' },
    end_name_tag_pattern   = { 'tag_name' },
    close_tag_pattern      = { 'ERROR' },
    close_name_tag_pattern = { 'ERROR', 'erroneous_end_tag_name' },
    element_tag            = { 'element' },
    skip_tag_pattern       = { 'quoted_attribute_value', 'end_tag' },
}

local TEMPL_TAG = {
    filetypes = {
        "templ",
    },
    start_tag_pattern = { "tag_start" },
    start_name_tag_pattern = { "element_identifier" },
    end_tag_pattern = { "tag_end" },
    end_name_tag_pattern = { "element_identifier" },
    close_tag_pattern = { "erroneous_end_tag" },
    close_name_tag_pattern = { "erroneous_end_tag_name" },
    element_tag = { "element" },
    skip_tag_pattern = { "quoted_attribute_value", "tag_end" },
}

local all_tag = {
    HBS_TAG,
    SVELTE_TAG,
    JSX_TAG,
    TEMPL_TAG,
}
M.enable_rename = true
M.enable_close = true
M.enable_close_on_slash = false

M.setup = function(opts)
    opts = opts or {}
    M.tbl_filetypes = opts.filetypes or M.tbl_filetypes
    M.tbl_skipTag = opts.skip_tag or M.tbl_skipTag
    if opts.enable_rename ~= nil then
        M.enable_rename = opts.enable_rename
    end
    if opts.enable_close ~= nil then
        M.enable_close = opts.enable_close
    end
    if opts.enable_close_on_slash ~= nil then
        M.enable_close_on_slash = opts.enable_close_on_slash
    end
end

local function is_in_table(tbl, val)
    if tbl == nil then
        return false
    end
    for _, value in pairs(tbl) do
        if val == value then
            return true
        end
    end
    return false
end

M.is_supported = function(lang)
    return is_in_table(M.tbl_filetypes, lang)
end

local buffer_tag = {}

local setup_ts_tag = function()
    local bufnr = vim.api.nvim_get_current_buf()
    for _, value in pairs(all_tag) do
        if is_in_table(value.filetypes, vim.bo.filetype) then
            buffer_tag[bufnr] = value
            return value
        end
    end
    buffer_tag[bufnr] = HTML_TAG
end

local function is_in_template_tag()
    local cursor_node = ts_utils.get_node_at_cursor()
    if not cursor_node then
        return false
    end

    local has_element = false
    local has_template_string = false

    local current_node = cursor_node
    while not (has_element and has_template_string) and current_node do
        if not has_element and current_node:type() == "element" then
            has_element = true
        end
        if not has_template_string and current_node:type() == "template_string" then
            has_template_string = true
        end
        current_node = current_node:parent()
    end

    return has_element and has_template_string
end

local function get_ts_tag()
    if is_in_template_tag() then
        return HTML_TAG
    else
        return buffer_tag[vim.api.nvim_get_current_buf()]
    end
end

local function find_child_match(opts)
    local target = opts.target
    local pattern = opts.pattern
    local skip_tag_pattern = opts.skip_tag_pattern
    if target == nil or pattern == nil then
        return nil
    end
    for _, ptn in pairs(pattern) do
        for node in target:iter_children() do
            local node_type = node:type()
            if node_type ~= nil and node_type == ptn and not is_in_table(skip_tag_pattern, node_type) then
                return node
            end
        end
    end
end

local function find_parent_match(opts)
    local target = opts.target
    local max_depth = opts.max_depth or 10
    local pattern = opts.pattern
    local skip_tag_pattern = opts.skip_tag_pattern
    if target == nil or pattern == nil then
        return nil
    end
    for _, ptn in pairs(pattern) do
        local cur_node = target
        local cur_depth = 0
        while cur_node ~= nil do
            local node_type = cur_node:type()
            if is_in_table(skip_tag_pattern, node_type) then
                return nil
            end
            if node_type ~= nil and node_type == ptn then
                return cur_node
            elseif cur_depth < max_depth then
                cur_depth = cur_depth + 1
                cur_node = cur_node:parent()
            else
                cur_node = nil
            end
        end
    end
    return nil
end

local function get_tag_name(node)
    local tag_name = nil
    if node ~= nil then
        tag_name = utils.get_node_text(node)[1]
        if tag_name and #tag_name > 3 then
            tag_name = tag_name:gsub("</", ""):gsub(">", ""):gsub("<", "")
        end
    end
    return tag_name
end

local function find_tag_node(opt)
    local target = opt.target or ts_utils.get_node_at_cursor()
    local tag_pattern = opt.tag_pattern
    local name_tag_pattern = opt.name_tag_pattern
    local skip_tag_pattern = opt.skip_tag_pattern
    local find_child = opt.find_child or false
    local node
    if find_child then
        node = find_child_match({
            target = target,
            pattern = tag_pattern,
            skip_tag_pattern = skip_tag_pattern,
        })
    else
        node = find_parent_match({
            target = target,
            pattern = tag_pattern,
            skip_tag_pattern = skip_tag_pattern,
        })
    end
    if node == nil then
        return nil
    end
    local name_node = find_child_match({
        target = node,
        pattern = name_tag_pattern,
    })
    if name_node then
        return name_node
    end

    -- check current node is have same name of tag_match
    if is_in_table(name_tag_pattern, node:type()) then
        return node
    end
    return name_node
end

local function find_child_tag_node(opt)
    opt.find_child = true
    return find_tag_node(opt)
end

local function find_start_tag(current)
    local ts_tag = get_ts_tag()
    if not ts_tag then
        return nil
    end
    local target = nil

    target = find_child_match({
        target = current:parent(),
        pattern = ts_tag.start_tag_pattern,
    })

    if target ~= nil then
        return target
    end

    target = find_child_match({
        target = current,
        pattern = ts_tag.start_tag_pattern,
    })

    return target
end

local function check_close_tag(close_slash_tag)
    local ts_tag = get_ts_tag()
    if not ts_tag then
        return false
    end

    local target = nil

    if close_slash_tag then
        -- Find start node from non closed tag
        local current = ts_utils.get_node_at_cursor()
        -- log.debug(current)
        target = find_start_tag(current)
        -- log.debug(target)
    end

    local tag_node = find_tag_node({
        target = target,
        tag_pattern = ts_tag.start_tag_pattern,
        name_tag_pattern = ts_tag.start_name_tag_pattern,
        skip_tag_pattern = ts_tag.skip_tag_pattern,
    })
    if tag_node ~= nil then
        local tag_name = get_tag_name(tag_node)
        if tag_name ~= nil and is_in_table(M.tbl_skipTag, tag_name) then
            return false
        end
        if tag_node ~= nil then
            -- case 6,9 check close on exist node
            local element_node = find_parent_match({
                target = tag_node,
                pattern = ts_tag.element_tag,
                max_depth = 2,
            })
            local close_tag_node = find_child_tag_node({
                target = element_node,
                tag_pattern = ts_tag.end_tag_pattern,
                name_tag_pattern = ts_tag.end_name_tag_pattern,
            })
            if close_tag_node ~= nil then
                local start_row = tag_node:range()
                local close_start_row = close_tag_node:range()
                if start_row == close_start_row and tag_name == get_tag_name(close_tag_node) then
                    return false
                end
            end
        end
        return true, tag_name
    end
    return false
end

M.close_tag = function()
    local buf_parser = parsers.get_parser()
    if not buf_parser then
        return
    end
    buf_parser:parse()
    local result, tag_name = check_close_tag()
    if result == true and tag_name ~= nil then
        vim.api.nvim_put({ string.format("</%s>", tag_name) }, "", true, false)
        vim.cmd([[normal! F>]])
    end
end

M.close_slash_tag = function()
    local buf_parser = parsers.get_parser()
    if not buf_parser then
        return
    end
    buf_parser:parse()
    local result, tag_name = check_close_tag(true)
    if result == true and tag_name ~= nil then
        vim.api.nvim_put({ string.format("%s>", tag_name) }, "", true, true)
        vim.cmd([[normal! F>]])
    end
end

local function replace_text_node(node, tag_name)
    if node == nil then
        return
    end
    local start_row, start_col, end_row, end_col = node:range()
    if start_row == end_row then
        local line = vim.fn.getline(start_row + 1)
        local newline = line:sub(0, start_col) .. tag_name .. line:sub(end_col + 1, string.len(line))
        vim.api.nvim_buf_set_lines(0, start_row, start_row + 1, true, { newline })
    end
end

local function validate_tag_regex(node, start_regex, end_regex)
    if node == nil then
        return false
    end
    local texts = utils.get_node_text(node)
    if string.match(texts[1], start_regex) and string.match(texts[#texts], end_regex) then
        return true
    end
    return false
end

local function validate_start_tag(node)
    return validate_tag_regex(node, "^%<%w", "%>$")
end

local function validate_close_tag(node)
    return validate_tag_regex(node, "^%<%/%w", "%>$")
end

local function rename_start_tag()
    local ts_tag = get_ts_tag()
    if not ts_tag then
        return
    end
    local tag_node = find_tag_node({
        tag_pattern = ts_tag.start_tag_pattern,
        name_tag_pattern = ts_tag.start_name_tag_pattern,
        skip_tag_pattern = ts_tag.skip_tag_pattern,
    })

    if tag_node == nil then
        return
    end
    if not validate_start_tag(tag_node:parent()) then
        return
    end

    local tag_name = get_tag_name(tag_node)
    local parent_node = tag_node

    tag_node = find_parent_match({
        target = parent_node,
        pattern = ts_tag.element_tag,
        max_depth = 2,
    })

    if tag_node == nil then
        return
    end

    local close_tag_node = find_child_tag_node({
        target = tag_node,
        tag_pattern = ts_tag.close_tag_pattern,
        name_tag_pattern = ts_tag.close_name_tag_pattern,
    })

    if close_tag_node == nil then
        close_tag_node = find_child_tag_node({
            target = tag_node:parent(),
            tag_pattern = ts_tag.close_tag_pattern,
            name_tag_pattern = ts_tag.close_name_tag_pattern,
        })
    end

    if close_tag_node ~= nil then
        log.debug(close_tag_node:type())
        local close_tag_name = get_tag_name(close_tag_node)
        -- verify parent node is same of close_tag_node (test case: 22)
        if close_tag_node ~= nil and tag_node ~= nil then
            local tag_parent = get_tag_name(tag_node:parent())
            -- log.debug(utils.dump_node(tag_node:parent()))
            if tag_parent == close_tag_name and not utils.verify_node(tag_node:parent(), close_tag_name) then
                log.debug("skip it have same")
                return
            end
        end
        if tag_name ~= close_tag_name then
            -- log.debug("do replace")
            -- log.debug(tag_name)
            -- log.debug(close_tag_name)
            if close_tag_name == '>' then
                tag_name = tag_name .. '>'
            end
            replace_text_node(close_tag_node, tag_name)
        end
    end
end

local function rename_end_tag()
    local ts_tag = get_ts_tag()
    if not ts_tag then
        return
    end
    local tag_node = find_tag_node({
        tag_pattern = ts_tag.close_tag_pattern,
        name_tag_pattern = ts_tag.close_name_tag_pattern,
    })
    if tag_node == nil then
        return
    end

    -- we check if that node text match </>
    if not (validate_close_tag(tag_node:parent()) or validate_close_tag(tag_node)) then
        return
    end

    local tag_name = get_tag_name(tag_node)
    tag_node = find_parent_match({
        target = tag_node,
        pattern = ts_tag.element_tag,
        max_depth = 2,
    })
    if tag_node == nil then
        return
    end
    local start_tag_node = find_child_tag_node({
        target = tag_node,
        tag_pattern = ts_tag.start_tag_pattern,
        name_tag_pattern = ts_tag.start_name_tag_pattern,
    })
    if start_tag_node and not validate_start_tag(start_tag_node:parent()) then
        return
    end
    if start_tag_node ~= nil then
        local start_tag_name = get_tag_name(start_tag_node)
        if tag_name ~= start_tag_name then
            log.debug('replace end tag')
            replace_text_node(start_tag_node, tag_name)
        end
    end
end

local function is_before(regex, range)
    return function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = vim.api.nvim_get_current_line()
        local char = line:sub(cursor[2] + range, cursor[2] + range)
        -- only rename when last character is a word
        if string.match(char, regex) then
            return true
        end
        return false
    end
end

local is_before_word = is_before('%w', 1)
local is_before_arrow = is_before('<', 0)

M.rename_tag = function()
    if is_before_word() and parsers.has_parser() then
        parsers.get_parser():parse()
        rename_start_tag()
        rename_end_tag()
    end
end

M.attach = function(bufnr, lang)
    M.lang = lang
    local config = configs.get_module("autotag")
    M.setup(config)

    if is_in_table(M.tbl_filetypes, vim.bo.filetype) then
        setup_ts_tag()
        local group = vim.api.nvim_create_augroup('nvim-ts-autotag', { clear = true })
        if M.enable_close == true then
            vim.api.nvim_buf_set_keymap(bufnr or 0, "i", ">", ">", {
                noremap = true,
                silent = true,
                callback = function()
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    vim.api.nvim_buf_set_text(bufnr or 0, row - 1, col, row - 1, col, { ">" })
                    M.close_tag()
                    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
                end,
            })
        end
        if M.enable_close_on_slash == true then
            vim.api.nvim_buf_set_keymap(bufnr or 0, "i", "/", "/", {
                noremap = true,
                silent = true,
                callback = function()
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    vim.api.nvim_buf_set_text(bufnr or 0, row - 1, col, row - 1, col, { "/" })
                    if is_before_arrow() then
                        log.debug('is_before_arrow')
                        M.close_slash_tag()
                    end
                    local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
                    vim.api.nvim_win_set_cursor(0, { new_row, new_col + 1 })
                end,
            })
        end
        if M.enable_rename == true then
            bufnr = bufnr or vim.api.nvim_get_current_buf()
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = group,
                buffer = bufnr,
                callback = M.rename_tag,
            })
        end
    end
end

M.detach = function(bufnr)
    local bufnr = tonumber(bufnr) or vim.api.nvim_get_current_buf()
    buffer_tag[bufnr] = nil
end

-- _G.AUTO = M
return M
