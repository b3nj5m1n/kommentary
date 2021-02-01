--[[--
Configuration.

This module contains the mappings of comment strings to filetypes, as well as
convenience functions for retrieving configuration parameters.
]]
local util = require("kommentary.util")
local default = {"//", {"/*", "*/"}}
local M = {}
--[[ These are the available modes that can be passed to
`kommentary.go`, we need to choose the appropriate one for
each mapping depending on the mode of the mapping ]]
M.context = util.enum({"line", "visual", "motion", "init"})

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
    --[[ The naming convention for these keymappings is: <Plug>kommentary_mode_suffix
    where suffix is either default, if it's the default behaviour, or a keyword
    indicating what is special about this mapping, for example consider the
    mapping `<Plug>kommentary_visual_singles`, this is a mapping for visual mode
    which will always use single-line comment style, instead of the default,
    which would be multi-line comment-style if the range is longer than one line. ]]
    -- Defaults
    vim.api.nvim_set_keymap('n', '<Plug>kommentary_motion_default',
        'v:lua.kommentary.go(' .. M.context.init .. ')',
        { noremap = true, expr = true })
    vim.api.nvim_set_keymap('n', '<Plug>kommentary_line_default',
        '<cmd>call v:lua.kommentary.go(' .. M.context.line .. ')<cr>',
        { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<Plug>kommentary_visual_default',
        '<cmd>call v:lua.kommentary.go(' .. M.context.visual .. ')<cr>',
        { noremap = true, silent = true })
    -- Non-default, Motion
    --[[ Atm, we can't pass a custom callback function to kommentary.go through
    a motion, from trying it out it seems as if you need to set the operatorfunc
    to a function, but without (), i.e. `v:lua.kommentary.go` instead of
    `v:lua.kommentary.go()`, because in the second example the function just
    wouldn't be called at all. Hopefully I missed something in the documentation. ]]
    -- Non-default, Line
    -- Non-default, Visual
    vim.api.nvim_set_keymap('v', '<Plug>kommentary_visual_singles',
        '<cmd>lua require("kommentary");kommentary.go(' .. M.context.visual .. ', '
        .. "{kommentary.toggle_comment_singles}" .. ')<cr>',
        { noremap = true, silent = false })
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
    ["haskell"] = {"--", {"{-", "-}"}},
    ["java"] = default,
    ["javascript"] = default,
    ["javascriptreact"] = default,
    ["kotlin"] = default,
    ["lua"] = {"--", {"--[[", "]]"}},
    ["markdown"] = {false, {"<!---", "-->"}},
    ["perl"] = {"#", false},
    ["python"] = {"#", false},
    ["r"] = {"#", false},
    ["ruby"] = {"#", false},
    ["rust"] = default,
    ["sh"] = {"#", false},
    ["sql"] = {"--", false},
    ["swift"] = default,
    ["typescript"] = default,
    ["typescriptreact"] = default,
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

--[[--
Generate a config table from a commentstring.
@tparam string commenting The commentstring to convert, see :h commentstring
@treturn {?bool|string,?bool{string,string}} Config table for commentstring
]]
function M.config_from_commentstring(commentstring)
    local placeholder = '%s'
    local index_placeholder = commentstring:find(util.escape_pattern(placeholder))
    if not index_placeholder then
        return default
    end
    index_placeholder = index_placeholder - 1
    --[[ Test if the commentstring is a single-line or multi-line comment,
    extract the appropriate fields into a table ]]
    if index_placeholder + #placeholder == #commentstring then
        return {commentstring:sub(1, -#placeholder-1), false}
    end
    return {false, {commentstring:sub(1, index_placeholder),
        commentstring:sub(index_placeholder + #placeholder + 1, -1)}}
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
        --[[ We can't get the commentstring for a filetype different from the
        current buffer, so in that case always return the default ]]
        return filetype == vim.bo.filetype
            and M.config_from_commentstring(vim.bo.commentstring) or default
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
