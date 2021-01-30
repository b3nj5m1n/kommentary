--[[--
Utility functions.

This module contains generic convenience functions.
(These are not specific to this plugin or neovim)
]]

--[[--
Trim leading and trailing whitespace from string.
@tparam string s String to trim
@treturn string String without leading or trailing whitespace
]]
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--[[--
Insert prefix before the first non-whitespace character in string.
@tparam string line String to which the prefix will be prepended
@tparam string prefix Prefix put at the beginning of the string
@treturn string String with prefix before first non-whitespace character
]]
local function insert_at_beginning(line, prefix)
    local start_index = string.find(line, "%S")
    return string.sub(line, 0, start_index-1) .. prefix .. string.sub(line, start_index, #line)
end

--[[--
Get the index of the last occurence of a pattern in a string.
@tparam string str String to search for the pattern
@tparam string pattern Pattern to search for
@treturn int Index of the beginning of the last occurence of the pattern in the string
]]
local function index_last_occurence(str, pattern)
    local result = 0
    local i = 0
    while true do
        i = str.find(pattern, i+1)
        if i == nil then break end
        result = i
    end
    return result
end

--[[--
Perform a gsub, starting only from a specific index.
@tparam string str String to gsub
@tparam string pattern Pattern to replace
@tparam string replacement What to replace the pattern with to replace
@tparam int count The maximum number of replacements to do
@tparam int start_index Where to start the gsub
@treturn string Gsubbed string
]]
local function gsub_from_index(str, pattern, replacement, count, start_index)
    -- Start index is exlusive
    local result = string.sub(str, 1, start_index) .. string.gsub(string.sub(str, start_index+1, #str), pattern, replacement, count)
    return result
end

--[[--
Escape special characters in string
@tparam string text String to escape
@treturn string String with all special chars escaped
]]
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

return {
    trim = trim,
    insert_at_beginning = insert_at_beginning,
    index_last_occurence = index_last_occurence,
    gsub_from_index = gsub_from_index,
    escape_pattern = escape_pattern,
}
