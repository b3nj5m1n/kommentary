--[[--
Configuration.

This module contains the mappings of comment strings to filetypes, as well as
convenience functions for retrieving configuration parameters.
]]
local util = require("kommentary.util")
--[[ The default values that will be used if commentstring isn't set,
and that will be used to fill in any missing values in user configuration.  Read:
single-line commentstring, multi-line commentstring, prefer multi-line comments,
prefer single-line comments, use consistent indentation, ignore empty lines. ]]
local M = {}
local default = {"//", {"/*", "*/"}, false, false, true, true}
function M.get_default_config() return default end
function M.set_default_config(new_default) default = new_default end
--[[ These are the available modes that can be passed to
`kommentary.go`, we need to choose the appropriate one for
each mapping depending on the mode of the mapping ]]
M.context = util.enum({"line", "visual", "motion", "init"})

--[[--
The default configuration, will be overwriten by user defined config.
The key in the table is the filetype for which the configuration should take effect.
The value is the configuration for that filetype, a table containing:
    * The prefix to be used for single-line comments, or "auto" for using commenstring.
    * A table containing the prefix and suffix to be used for multi-line comments,
        or "auto" for using commenstring.
    * A bool, if set to true the default mode will be set to prefer_multi,
        meaning multi-line comments will be used when available.
    * A bool, if set to true the default mode will be set to prefer_single,
        meaning single-line comments will be used when available.
    * A bool, if set to true consistent indentation will be used in
        multi-single comments.
    Any missing values, or when they're set to "default", will be filled in with
        the default values.
A language will get an explicit configuration here if the commentstring is not defined,
or if it supports both single-line and multi-line comments. For example:
    * bash doesn't get in, it only supports single-line comments and the
        commentstring is set correctly for it.
    * c does get in because it supports both single-line and multi-line
        comments.
    * fennel does get in because the commentstring isn't set for it.
]]
M.config = {
    ["c"] = {},
    ["clojure"] = {";", {"(comment ", " )"}},
    ["cpp"] = {},
    ["cs"] = {},
    ["fennel"] = {";", false},
    ["go"] = {},
    ["haskell"] = {"--", {"{-", "-}"}},
    ["java"] = {},
    ["javascript"] = {},
    ["javascriptreact"] = {"auto", "auto"},
    ["kotlin"] = {},
    ["lua"] = {"--", {"--[[", "]]"}},
    ["rust"] = {},
    ["sql"] = {"--", {"/*", "*/"}},
    ["swift"] = {},
    ["typescript"] = {},
    ["typescriptreact"] = {"auto", "auto"},
}

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
    -- This is the global variable holding the callback function to be called by go()
    vim.api.nvim_set_var("kommentary_callback_function", nil)
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
    vim.api.nvim_set_keymap('n', '<Plug>kommentary_motion_singles',
        'v:lua.kommentary.go(' .. M.context.init .. ', ' ..
        "'kommentary.toggle_comment_singles'" .. ')',
        { noremap = true, expr = true })
    -- Non-default, Line
    -- Non-default, Visual
    vim.api.nvim_set_keymap('v', '<Plug>kommentary_visual_singles',
        '<cmd>lua require("kommentary");kommentary.go(' .. M.context.visual .. ', '
        .. "'kommentary.toggle_comment_singles'" .. ')<cr>',
        { noremap = true, silent = true })
end

--[[--
Interface for creating configuration entries.
@tparam string language The name of the language
@tparam table options The options to set, possible values:
        single_line_comment_string (string) the prefix for single-line comments
        multi_line_comment_strings (string tuple) the prefix and suffix
        prefer_single_line_comments (bool) if true, prefer the use of
            single-line comments
        prefer_multi_line_comments (bool) if true, prefer the use
            of multi-line comments
        use_consistent_indentation (bool) if true, use the outer-most indentation
            level for all single-line comments in a multi-single-line comment:
                ```lua
                -- function test()
                    -- print("Multi-single-line comment, inconsistent indentation.")
                -- end
                ```
                ```lua
                -- function test()
                --     print("Multi-single-line comment, consistent indentation.")
                -- end
                ```
        ignore_whitespace (bool) if true, ignore empty lines when commenting out a
            range with single-line commtents:
                ```lua
                -- function test_function_1()
                --     print("test")
                -- end
                --
                -- function test_function_2()
                --     print("test")
                -- end
                ```
                ```lua
                -- function test_function_1()
                --     print("test")
                -- end

                -- function test_function_2()
                --     print("test")
                -- end
                ```
        dont_fill_defaults  by default, for options not provided in the options table,
            the option will be set according to the default value of that option,
            if this option is present, options not provided will be left at nil.
]]
function M.configure_language(language, options)
    local result = {nil, nil, nil, nil, nil}
    local dont_fill_defaults = options.dont_fill_defaults ~= nil
    --[[ For every option available, test if it present in the provided options table,
    if so, set the value from the provided options, if not, and fill_defaults is
    enabled, set to the default value. ]]
    if options.single_line_comment_string ~= nil then
        result[1] = options.single_line_comment_string
    elseif not dont_fill_defaults then
        result[1] = M.get_default_config()[1]
    end
    if options.multi_line_comment_strings ~= nil then
        result[2] = options.multi_line_comment_strings
    elseif not dont_fill_defaults then
        result[2] = M.get_default_config()[2]
    end
    if options.prefer_single_line_comments ~= nil then
        result[3] = options.prefer_single_line_comments
    elseif not dont_fill_defaults then
        result[3] = M.get_default_config()[3]
    end
    if options.prefer_multi_line_comments ~= nil then
        result[4] = options.prefer_multi_line_comments
    elseif not dont_fill_defaults then
        result[4] = M.get_default_config()[4]
    end
    if options.use_consistent_indentation ~= nil then
        result[5] = options.use_consistent_indentation
    elseif not dont_fill_defaults then
        result[5] = M.get_default_config()[5]
    end
    if options.ignore_whitespace ~= nil then
        result[6] = options.ignore_whitespace
    elseif not dont_fill_defaults then
        result[6] = M.get_default_config()[6]
    end
    if language == "default" then
        M.set_default_config(result)
        return
    end
    M.config[language] = result
end

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
@tparam string commentstring The commentstring to convert, see :h commentstring
@treturn {?bool|string,?bool{string,string}} Config table for commentstring
]]
function M.config_from_commentstring(commentstring)
    local placeholder = '%s'
    local index_placeholder = commentstring:find(util.escape_pattern(placeholder))
    if not index_placeholder then
        return M.default
    end
    index_placeholder = index_placeholder - 1
    --[[ Test if the commentstring is a single-line or multi-line comment,
    extract the appropriate fields into a table ]]
    if index_placeholder + #placeholder == #commentstring then
        return {util.trim(commentstring:sub(1, -#placeholder-1)), false}
    end
    return {false, {util.trim(commentstring:sub(1, index_placeholder)),
        util.trim(commentstring:sub(index_placeholder + #placeholder + 1, -1))}}
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
            and M.config_from_commentstring(vim.bo.commentstring) or M.default
    end
    local result = {unpack(M.config[filetype])}
    -- Fill in missing or "default" fields
    for i = 1,6,1 do
        if result[i] == "default" or result[i] == nil then
            result[i] = M.get_default_config()[i]
        end
    end
    if result[1] == "auto" then
        result[1] = M.config_from_commentstring(vim.bo.commentstring)[1]
    end
    if result[2] == "auto" then
        result[2] = M.config_from_commentstring(vim.bo.commentstring)[2]
    end
    return result
end

--[[--
Get the default mode (Prefer either multi or single line comments, or neither).
@tparam string filetype The filetype for which to retrieve the default mode
@treturn int *Enum*
]]
function M.get_default_mode(filetype)
    local config = M.get_config(filetype)
    local modes = M.get_modes()
    --[[ If both prefer_multi and prefer_single are set, or if none of them are
    set, use the default mode. ]]
    if (config[3] and config[4]) or (not config[3] and not config[4]) then
        return modes.normal
    end
    if config[3] then
        return modes.force_single
    end
    if config[4] then
        return modes.force_multi
    end
end

--[[--
Decide which mode should ultimately be used.
If the function has been called with something other than mode.normal, that will be
    what is used and it is immediately returned.
If line_number_start and line_number_end are the same, so if the range is only
    a single line long, single-line comments will be used.
If a default mode other than modes.normal has been set for the language, the mode
    will be set to that default mode. (Overwrites previous)
If the language doesn't support multi-line comments,
    single-lines will be used. (Overwrites previous)
If the language doesn't support single line comments,
    multi-line comments will be used. (Overwrites previous)
@treturn int *Enum*
]]
function M.get_mode(line_number_start, line_number_end, mode)
    local modes = M.get_modes()
    local config = M.get_config(0)
    --[[ The function was called with something non-default,
    this overwrites everything else. ]]
    if mode ~= modes.normal then
        return mode
    end
    -- If the range is only 1 line long, use single-line comments
    if line_number_start == line_number_end then
        mode = modes.force_single
    end
    local default_mode = M.get_default_mode(0)
    if default_mode ~= modes.normal then
        mode = default_mode
    end
    -- If the language doesn't support multi-line comments
    if config[2] == false then
        mode = modes.force_single
    -- If the language doesn't support single-line comments
    elseif config[1] == false then
        mode = modes.force_multi
    end
    return mode
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
