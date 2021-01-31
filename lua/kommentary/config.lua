--[[--
Configuration.

This module contains the mappings of comment strings to filetypes, as well as
convenience functions for retrieving configuration parameters.
]]
local util = require("kommentary.util")
local default = {"//", {"/*", "*/"}}
local M = {}

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
function M.setup()
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
M.config = {
    ["bash"] = {"#", false},
    ["c"] = default,
    ["clojure"] = {";", {"(comment ", " )"}},
    ["cpp"] = default,
    ["cs"] = default,
    ["fennel"] = {";", false},
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
    ["sh"] = {"#", false},
    ["swift"] = default,
    ["vim"] = {"\"", false},
    ["zsh"] = {"#", false},
}

--[[--
Check if configuration for filetype exists.
@tparam string filetype Filetype to check
@treturn bool true if a config is available, otherwise false
]]
function M.has_filetype(filetype)
    return M.config[filetype] ~= nil
end

function M.config_from_commentstring(commentstring)
    if commenstring == "/*%s*/" then return default end
    local placeholder = '%s'
    local where = commentstring:find(util.escape_pattern(placeholder))
    if not where then
        return default
    end
    where = where - 1
    if where + #placeholder == #commentstring then
        return {commentstring:sub(1, -#placeholder-1), false}
    end
    return {false, {commentstring:sub(1, where),  commentstring:sub(where + #placeholder + 1, -1)}}
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
function M.get_config(filetype)
    if filetype == 0 then
        filetype = vim.bo.filetype
    end
    if not M.has_filetype(filetype) then
        return M.config_from_commentstring(vim.bo.commentstring)
    end
    return M.config[filetype]
end

--[[--
Get the single-line comment string for the given filetype.
@tparam string filetype Filetype to retrieve configuration for,
	0 means infere by current buffer.
	If the filetype doesn't have a configuration available,
	the default configuration will be returned.
@treturn ?bool|string Single-line comment string for filetype
]]
function M.get_single(filetype)
    return M.get_config(filetype)[1]
end

--[[--
Get the multi-line comment string for the given filetype.
@tparam string filetype Filetype to retrieve configuration for,
	0 means infere by current buffer.
	If the filetype doesn't have a configuration available,
	the default configuration will be returned.
@treturn ?bool|{string,string} Multi-line comment strings for filetype
]]
function M.get_multi(filetype)
    return M.get_config(filetype)[2]
end

--[[--
Get the enum for available modes.
@treturn {{string,int},...} *Enum*
]]
function M.get_modes()
    return util.enum( {
        "normal",
        "force_multi",
        "force_single",
        })
end

return M
