--[[--
Configuration.

This module contains the mappings of comment strings to filetypes, as well as
convenience functions for retrieving configuration parameters.
]]
local default = {"//", {"/*", "*/"}}

--[[--
Set up keymappings.
Sets up <Plug>Kommentary, to this you should map the prefix you want to use for
	motions, so for example if you want to be able to to gc5j to toggle comments
	for the next 5 lines, do this: `nmap gc <Plug>Kommentary`.
Sets up <Plug>KommentaryVisual, which is obviously for the visual mode mapping,
	for example to be able to do gc in visual mode, do this mapping:
	`vmap gc <Plug>KommentaryVisual`, this will leave you in visual mode after
	toggeling comments, if you always want to go back to normal mode afterwards:
	`vmap gc <Plug>KommentaryVisual<C-c>`
Sets up <Plug>KommentaryLine, which is what you should use for commenting out single
	lines, so if you want to be able to do gcc in normal mode to comment out the
	line you're currently on, do this: `nmap gcc <Plug>KommentaryLine`
@treturn nil
]]
local function setup()
    vim.api.nvim_set_keymap('n', '<Plug>Kommentary', 'v:lua.kommentary.toggle_comment()', { noremap = true, expr = true })
    vim.api.nvim_set_keymap('n', '<Plug>KommentaryLine', '<cmd>call v:lua.kommentary.toggle_comment("single_line")<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<Plug>KommentaryVisual', '<cmd>call v:lua.kommentary.toggle_comment("visual")<cr>', { noremap = true, silent = true })
end

--[[--
Table mapping filetypes to comment strings.
Configuration for each filetype, the first field is the prefix for a single
line comment, the second field is either false, if multi-line comments aren't
supported by that filetype, or a table where the first field is the prefix
for a multi-line comment and the second field is the suffix. Note that the very
first field can also be false, if a language always requires a pre- and suffix.
Newlines are not allowed, since they can't be matched when commenting out.
]]
local config_table = {
    ["bash"] = {"#", false},
    ["c"] = default,
    ["clojure"] = {";", {"(comment ", " )"}},
    ["cpp"] = default,
    ["cs"] = default,
    ["fennnel"] = {";", false},
    ["fish"] = {"#", false},
    ["go"] = default,
    ["java"] = default,
    ["javascript"] = default,
    ["kotlin"] = default,
    ["lua"] = {"--", {"--[[", "]]"}},
    ["markdown"] = {false, {"<!---", "-->"}},
    ["python"] = {"#", false},
    ["r"] = {"#", false},
    ["ruby"] = {"#", false},
    ["rust"] = default,
    ["swift"] = default,
    ["vim"] = {"\"", false},
    ["zsh"] = {"#", false}
}

--[[--
Check if configuration for filetype exists.
@tparam string filetype Filetype to check
@treturn bool true if a config is available, otherwise false
]]
local function has_filetype(filetype)
    return config_table[filetype] ~= nil
end

--[[--
Get the full config for the given filetype.
@tparam string filetype Filetype to retrieve configuration for,
	0 means infere by current buffer.
	If the filetype doesn't have a configuration available,
	the default configuration will be returned.
@treturn {[string]={?bool|string,?bool|{string,string}}}
	Full configuration for filetype
]]
local function get_config(filetype)
    if filetype == 0 then
        filetype = vim.bo.filetype
    end
    if not has_filetype(filetype) then
        return default
    end
    return config_table[filetype]
end

--[[--
Get the single-line comment string for the given filetype.
@tparam string filetype Filetype to retrieve configuration for,
	0 means infere by current buffer.
	If the filetype doesn't have a configuration available,
	the default configuration will be returned.
@treturn ?bool|string Single-line comment string for filetype
]]
local function get_single(filetype)
    return get_config(filetype)[1]
end

--[[--
Get the multi-line comment string for the given filetype.
@tparam string filetype Filetype to retrieve configuration for,
	0 means infere by current buffer.
	If the filetype doesn't have a configuration available,
	the default configuration will be returned.
@treturn ?bool|{string,string} Multi-line comment strings for filetype
]]
local function get_multi(filetype)
    return get_config(filetype)[2]
end

return {
    setup = setup,
    config = config_table,
    get_single = get_single,
    get_multi = get_multi,
}
