local FiletypeConfig = require("nvim-ts-autotag.config.ft")
local TagConfigs = require("nvim-ts-autotag.config.init")

local function setup_tag_configs()
    ---@diagnostic disable-next-line: param-type-mismatch
    local base_cfg = FiletypeConfig:extend(nil, {
        skip_tag_pattern = {
            "area",
            "base",
            "br",
            "col",
            "command",
            "embed",
            "hr",
            "img",
            "slot",
            "input",
            "keygen",
            "link",
            "meta",
            "param",
            "source",
            "track",
            "wbr",
            "menuitem",
        },
    })

    local html_tag_cfg = base_cfg:extend("html", {
        start_tag_pattern = { "start_tag", "STag" },
        start_name_tag_pattern = { "tag_name", "Name" },
        end_tag_pattern = { "end_tag", "ETag" },
        end_name_tag_pattern = { "tag_name", "Name" },
        close_tag_pattern = { "erroneous_end_tag" },
        close_name_tag_pattern = { "erroneous_end_tag_name" },
        element_tag = { "element" },
        skip_tag_pattern = { "quoted_attribute_value", "end_tag" },
    })

    TagConfigs:add(html_tag_cfg)
    TagConfigs:add(html_tag_cfg:override("xml", {
        start_tag_pattern = { "STag" },
        end_tag_pattern = { "ETag" },
    }))

    TagConfigs:add(base_cfg:extend("typescriptreact", {
        start_tag_pattern = { "jsx_opening_element", "start_tag" },
        start_name_tag_pattern = {
            "identifier",
            "nested_identifier",
            "tag_name",
            "member_expression",
            "jsx_identifier",
        },
        end_tag_pattern = { "jsx_closing_element", "end_tag" },
        end_name_tag_pattern = { "identifier", "tag_name" },
        close_tag_pattern = { "jsx_closing_element", "nested_identifier" },
        close_name_tag_pattern = { "member_expression", "nested_identifier", "jsx_identifier", "identifier", ">" },
        element_tag = { "jsx_element", "element" },
        skip_tag_pattern = {
            "jsx_closing_element",
            "jsx_expression",
            "string",
            "jsx_attribute",
            "end_tag",
            "string_fragment",
        },
    }))

    TagConfigs:add(base_cfg:extend("glimmer", {
        start_tag_pattern = { "element_node_start" },
        start_name_tag_pattern = { "tag_name" },
        end_tag_pattern = { "element_node_end" },
        end_name_tag_pattern = { "tag_name" },
        close_tag_pattern = { "element_node_end" },
        close_name_tag_pattern = { "tag_name" },
        element_tag = { "element_node" },
        skip_tag_pattern = { "element_node_end", "attribute_node", "concat_statement" },
    }))

    TagConfigs:add(base_cfg:extend("svelte", {
        start_tag_pattern = { "start_tag" },
        start_name_tag_pattern = { "tag_name" },
        end_tag_pattern = { "end_tag" },
        end_name_tag_pattern = { "tag_name" },
        close_tag_pattern = { "erroneous_end_tag" },
        close_name_tag_pattern = { "erroneous_end_tag_name" },
        element_tag = { "element" },
        skip_tag_pattern = { "quoted_attribute_value", "end_tag" },
    }))

    TagConfigs:add(base_cfg:extend("templ", {
        start_tag_pattern = { "tag_start" },
        start_name_tag_pattern = { "element_identifier" },
        end_tag_pattern = { "tag_end" },
        end_name_tag_pattern = { "element_identifier" },
        close_tag_pattern = { "erroneous_end_tag" },
        close_name_tag_pattern = { "erroneous_end_tag_name" },
        element_tag = { "element" },
        skip_tag_pattern = { "quoted_attribute_value", "tag_end" },
    }))
end

---@class nvim-ts-autotag.Opts
---@field enable_rename boolean? Whether or not to auto rename paired tags
---@field enable_close boolean? Whether or not to auto close tags
---@field enable_close_on_slash boolean? Whether or not to auto close tags when a `/` is inserted
local Opts = {
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = false,
}

---@class nvim-ts-autotag.PluginSetup
---@field private did_setup boolean
---@field opts nvim-ts-autotag.Opts? General setup optionss
---@field aliases { [string]: string }? Aliases a filetype to an existing filetype tag config
---@field per_filetype { [string]: nvim-ts-autotag.Opts }? Per filetype config overrides
local Setup = {
    did_setup = false,
    opts = Opts,
    aliases = {
        ["astro"] = "html",
        ["eruby"] = "html",
        ["vue"] = "html",
        ["htmldjango"] = "html",
        ["markdown"] = "html",
        ["php"] = "html",
        ["twig"] = "html",
        ["blade"] = "html",
        ["javascriptreact"] = "typescriptreact",
        ["javascript.jsx"] = "typescriptreact",
        ["typescript.tsx"] = "typescriptreact",
        ["javascript"] = "typescriptreact",
        ["typescript"] = "typescriptreact",
        ["rescript"] = "typescriptreact",
        ["handlebars"] = "glimmer",
        ["hbs"] = "glimmer",
    },
    per_filetype = {},
}

--- Do general plugin setup
---@param opts nvim-ts-autotag.PluginSetup
function Setup.setup(opts)
    opts = opts or {}
    if Setup.did_setup then
        return
    end
    ---@diagnostic disable-next-line: undefined-field
    if opts.enable_rename or opts.enable_close or opts.enable_close_on_slash then
        vim.notify(
            "nvim-ts-autotag: Using the legacy setup opts! Please migrate to the new setup options layout as this will eventually have its support removed in 1.0.0!",
            vim.log.levels.WARN
        )
        opts = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            opts = opts,
        }
    end
    Setup = vim.tbl_deep_extend("force", Setup, opts or {})

    if not Setup.did_setup then
        Setup.did_setup = true

        setup_tag_configs()
        for new_ft, existing_ft in pairs(Setup.aliases) do
            TagConfigs:add_alias(new_ft, existing_ft)
        end
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
end

--- Get the defined options for the given filetype or in general
---@param filetype string?
---@return nvim-ts-autotag.Opts
function Setup.get_opts(filetype)
    if not filetype then
        return Setup.opts
    end

    local per_ft_conf = Setup.per_filetype[filetype]
    if per_ft_conf then
        return vim.tbl_deep_extend("force", Setup.opts or {}, per_ft_conf)
    end

    return Setup.opts
end

return Setup
