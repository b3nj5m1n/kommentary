--[[--
Configuration.

This module contains the mappings of comment strings to filetypes, as well as
convenience functions for retrieving configuration parameters.
]]
local util = require("kommentary.util")
--[[ The default values that will be used if commentstring isn't set,
and that will be used to fill in any missing values in user configuration.  Read:
single-line commentstring, multi-line commentstring, prefer multi-line comments,
prefer single-line comments, use consistent indentation, ignore empty lines,
pre-execute hook function. ]]
local M = {}
local default = {"//", {"/*", "*/"}, false, false, true, true, nil}
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
    ["elixir"] = {"#", false, true},
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
    ["toml"] = {"#", false},
    ["typescript"] = {},
    ["typescriptreact"] = {"auto", "auto"},
}

function M.get_lang_default(language)
    if M.config[language] ~= nil then
        return M.config[language]
    end
    return M.get_default_config()
end

function M.add_keymap(mode, name, context, options, callback)
    local default_options = { noremap = true, silent = true, expr = false }
    if options ~= nil then
        for option, value in pairs(options) do
            default_options[option] = value
        end
    end
    name = '<Plug>' .. name
    callback = (callback ~= nil and ', ' .. "'" ..  callback .. "'" or '')
    local action = (context == M.context.init and '' or '<cmd>call ')
        .. 'v:lua.kommentary.go(' .. context .. callback .. ')'
        .. (default_options["expr"] == true and '' or '<cr>')
    vim.api.nvim_set_keymap(mode, name, action, default_options)
end

--[[--
Set up keymappings.
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
    M.add_keymap("n", "kommentary_motion_default", M.context.init, { expr = true })
    M.add_keymap("n", "kommentary_line_default", M.context.line)
    M.add_keymap("x", "kommentary_visual_default", M.context.visual)
    -- Increase comment level
    M.add_keymap("n", "kommentary_motion_increase", M.context.init, { expr = true },
        "kommentary.increase_comment_level")
    M.add_keymap("n", "kommentary_line_increase", M.context.line, {},
        "kommentary.increase_comment_level")
    M.add_keymap("x", "kommentary_visual_increase", M.context.visual, {},
        "kommentary.increase_comment_level")
    -- Decrease comment level
    M.add_keymap("n", "kommentary_motion_decrease", M.context.init, { expr = true },
        "kommentary.decrease_comment_level")
    M.add_keymap("n", "kommentary_line_decrease", M.context.line, {},
        "kommentary.decrease_comment_level")
    M.add_keymap("x", "kommentary_visual_decrease", M.context.visual, {},
        "kommentary.decrease_comment_level")

  --[[ If the user has set the g:kommentary_create_default_mappings variable,
   use that value, otherwise default to creating the mappings ]]
  local create_default_mappings = vim.g.kommentary_create_default_mappings
  if create_default_mappings == nil or create_default_mappings == 1 then
    M.use_default_mappings()
  end
end

--[[--
Creates mappings familiar from vim-commentary.
]]
function M.use_default_mappings()
    --[[ The default mapping for line-wise operation; will toggle the range from
    commented to not-commented and vice-versa, will use a single-line comment. ]]
    vim.api.nvim_set_keymap("n", "gcc", "<Plug>kommentary_line_default", {})
    --[[ The default mapping for visual selections; will toggle the range from
    commented to not-commented and vice-versa, will use multi-line comments when
    the range is longer than 1 line, otherwise it will use a single-line comment. ]]
    vim.api.nvim_set_keymap("x", "gc", "<Plug>kommentary_visual_default<C-c>", {})
    --[[ The default mapping for motions; will toggle the range from commented to
    not-commented and vice-versa, will use multi-line comments when the range
    is longer than 1 line, otherwise it will use a single-line comment. ]]
    vim.api.nvim_set_keymap("n", "gc", "<Plug>kommentary_motion_default", {})
end

--[[--
Creates mappings for in/decreasing comment level.
]]
function M.use_extended_mappings()
    vim.api.nvim_set_keymap("n", "<leader>cic", "<Plug>kommentary_line_increase", {})
    vim.api.nvim_set_keymap("n", "<leader>ci", "<Plug>kommentary_motion_increase", {})
    vim.api.nvim_set_keymap("x", "<leader>ci", "<Plug>kommentary_visual_increase", {})
    vim.api.nvim_set_keymap("n", "<leader>cdc", "<Plug>kommentary_line_decrease", {})
    vim.api.nvim_set_keymap("n", "<leader>cd", "<Plug>kommentary_motion_decrease", {})
    vim.api.nvim_set_keymap("x", "<leader>cd", "<Plug>kommentary_visual_decrease", {})
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
        hook_function (function) a function to call before returning a config
]]
function M.configure_language(language, options)
    local result = {nil, nil, nil, nil, nil, nil}
    local dont_fill_defaults = options.dont_fill_defaults ~= nil
    local defaults = M.get_lang_default(language)
    if dont_fill_defaults then
        defaults = {nil, nil, nil, nil, nil}
    end
    --[[ For every option available, test if it present in the provided options table,
    if so, set the value from the provided options, if not, and fill_defaults is
    enabled, set to the default value. ]]
    if options.single_line_comment_string ~= nil then
        result[1] = options.single_line_comment_string
    elseif not dont_fill_defaults then
        result[1] = defaults[1]
    end
    if options.multi_line_comment_strings ~= nil then
        result[2] = options.multi_line_comment_strings
    elseif not dont_fill_defaults then
        result[2] = defaults[2]
    end
    if options.prefer_single_line_comments ~= nil then
        result[3] = options.prefer_single_line_comments
    elseif not dont_fill_defaults then
        result[3] = defaults[3]
    end
    if options.prefer_multi_line_comments ~= nil then
        result[4] = options.prefer_multi_line_comments
    elseif not dont_fill_defaults then
        result[4] = defaults[4]
    end
    if options.use_consistent_indentation ~= nil then
        result[5] = options.use_consistent_indentation
    elseif not dont_fill_defaults then
        result[5] = defaults[5]
    end
    if options.ignore_whitespace ~= nil then
        result[6] = options.ignore_whitespace
    elseif not dont_fill_defaults then
        result[6] = defaults[6]
    end
    if options.hook_function ~= nil then
        result[7] = options.hook_function
    elseif not dont_fill_defaults then
        result[7] = defaults[7]
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
    local index_placeholder = commentstring:find(vim.pesc(placeholder))
    if not index_placeholder then
        return M.get_default_config()
    end
    index_placeholder = index_placeholder - 1
    --[[ Test if the commentstring is a single-line or multi-line comment,
    extract the appropriate fields into a table ]]
    if index_placeholder + #placeholder == #commentstring then
        return {vim.trim(commentstring:sub(1, -#placeholder-1)), false}
    end
    return {false, {vim.trim(commentstring:sub(1, index_placeholder)),
        vim.trim(commentstring:sub(index_placeholder + #placeholder + 1, -1))}}
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
    local result = nil
    if M.has_filetype(filetype) then
        hook = M.config[filetype][7]
        if hook ~= nil then
            hook()
        end
        result = {unpack(M.config[filetype])}
    else
        --[[ We can't get the commentstring for a filetype different from the
        current buffer, so in that case always return the default ]]
        result = filetype == vim.bo.filetype
            and M.config_from_commentstring(vim.bo.commentstring) or M.get_default_config()
    end
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
