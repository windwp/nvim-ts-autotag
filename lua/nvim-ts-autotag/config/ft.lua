local utils = require("nvim-ts-autotag.utils")

---@alias nvim-ts-autotag.FiletypeConfigPattern string[] A single array of patterns

---@alias nvim-ts-autotag.FiletypeConfig.filetype string The supported filetype for a given Filetype Config

-- WARN: IF YOU MESS WITH THE FIELDS IN THIS, MAKE ABSOLUTELY SURE YOU UPDATE THE PARTIAL PATTERNS
-- IN THE NEXT CLASS AS WELL!
--
---@class nvim-ts-autotag.FiletypeConfig.patterns The patterns used in a tag search
---@field start_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field start_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field end_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field end_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field close_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field close_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern
---@field element_tag nvim-ts-autotag.FiletypeConfigPattern
---@field skip_tag_pattern nvim-ts-autotag.FiletypeConfigPattern

---@class nvim-ts-autotag.FiletypeConfig.patterns.p Partial patterns, lua_ls doesn't have partial support so this has to copied 🙁
---@field start_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field start_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field end_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field end_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field close_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field close_name_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?
---@field element_tag nvim-ts-autotag.FiletypeConfigPattern?
---@field skip_tag_pattern nvim-ts-autotag.FiletypeConfigPattern?

---@class nvim-ts-autotag.FiletypeConfig
---@field filetype nvim-ts-autotag.FiletypeConfig.filetype If nil, then this is acting as a base
---@field patterns nvim-ts-autotag.FiletypeConfig.patterns
local FiletypeConfig = {
    filetype = "",
    patterns = {
        start_tag_pattern = {},
        start_name_tag_pattern = {},
        end_tag_pattern = {},
        end_name_tag_pattern = {},
        close_tag_pattern = {},
        close_name_tag_pattern = {},
        element_tag = {},
        skip_tag_pattern = {},
    },
}

---@param filetype nvim-ts-autotag.FiletypeConfig.filetype
---@param patterns nvim-ts-autotag.FiletypeConfig.patterns
---@return nvim-ts-autotag.FiletypeConfig
function FiletypeConfig.new(filetype, patterns)
    local new = {
        filetype = filetype,
        patterns = patterns,
    }
    return setmetatable(new, {
        __index = FiletypeConfig,
    })
end

--- Creates a deep copy of the given FiletypeConfig
---@private
---@return nvim-ts-autotag.FiletypeConfig
function FiletypeConfig:clone()
    return vim.deepcopy(self)
end

--- Allows overriding of patterns for a config and returns the overriden config
---@param filetype nvim-ts-autotag.FiletypeConfig.filetype
---@param patterns nvim-ts-autotag.FiletypeConfig.patterns.p
---@return nvim-ts-autotag.FiletypeConfig
function FiletypeConfig:override(filetype, patterns)
    local new = self:clone()
    new.filetype = filetype
    new.patterns = vim.tbl_deep_extend("force", new.patterns, patterns or {})
    return new
end

--- Adds additional values to a given config's patterns, updates the supported filetype, and
--- returns a new extended cfg
---@param filetype nvim-ts-autotag.FiletypeConfig.filetype
---@param patterns nvim-ts-autotag.FiletypeConfig.patterns.p?
---@return nvim-ts-autotag.FiletypeConfig
function FiletypeConfig:extend(filetype, patterns)
    local new = self:clone()
    new.filetype = filetype
    for pat_key, pats in pairs(patterns or {}) do
        for _, pat in ipairs(pats) do
            if not utils.list_contains(new.patterns[pat_key], pat) then
                table.insert(new.patterns[pat_key], pat)
            end
        end
    end
    return new
end

return FiletypeConfig
