---@class nvim-ts-autotag.TagConfigs
---@field private _cfgs { [string]: nvim-ts-autotag.FiletypeConfig }
local TagConfigs = {
    _cfgs = {},
}

---@param filetype string The filetype to get the tag config for
---@return nvim-ts-autotag.FiletypeConfig?
function TagConfigs:get(filetype)
    return self._cfgs[filetype]
end

--- Get tag patterns by a filetype
---@param filetype string The filetype to get the tag patterns for
---@return nvim-ts-autotag.FiletypeConfig.patterns?
function TagConfigs:get_patterns(filetype)
    local cfg = self._cfgs[filetype]
    if cfg then
        return cfg.patterns
    end
end

---@param tag_config nvim-ts-autotag.FiletypeConfig
function TagConfigs:add(tag_config)
    self._cfgs[tag_config.filetype] = tag_config
end

--- Directly updates a given tag config stored in the TagConfigs
---@param tag_config nvim-ts-autotag.FiletypeConfig
function TagConfigs:update(tag_config)
    self._cfgs[tag_config] = tag_config
end

--- Get a list of supported filetypes
---@return string[]
function TagConfigs:get_supported_filetypes()
    local supported_fts = {}
    for ft, _ in pairs(self._cfgs) do
        table.insert(supported_fts, ft)
    end
    return supported_fts
end

--- Adds an alias for to an existing tag config for a new filetype
---
--- For example, to an add an alias for say a filetype named `quill` that we want to use the `html`
--- tag config for we can do the following:
---
--- ```lua
--- TagConfigs:add_alias("quill", "html")
--- ```
---@param new_filetype string The new filetype to alias for
---@param existing_filetype string The existing filetype to link to
function TagConfigs:add_alias(new_filetype, existing_filetype)
    local existing_cfg = self:get(existing_filetype)
    if not existing_cfg then
        error(("No existing filetype '%s' to alias to!"):format(existing_filetype))
    end
    local new = existing_cfg:extend(new_filetype)
    self:add(new)
end

--- A simple wrapper around `TagConfigs.add_alias`.
---
--- Adds multiple aliases to an existing tag config for new filetypes.
---
--- ```lua
--- TagConfigs:add_aliases({ "quill", "vue"}, "html")
-- ```
---@param new_filetypes string[] The new filetypes to alias for
---@param existing_filetype string The existing filetype to link to
function TagConfigs:add_aliases(new_filetypes, existing_filetype)
    for _, new_ft in ipairs(new_filetypes) do
        self:add_alias(new_ft, existing_filetype)
    end
end

return TagConfigs
