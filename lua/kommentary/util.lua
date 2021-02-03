--[[--
Utility functions.

This module contains generic convenience functions.
(These are not specific to this plugin or neovim)
]]
local M = {}

--[[--
Trim leading and trailing whitespace from string.
@tparam string s String to trim
@treturn string String without leading or trailing whitespace
]]
function M.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--[[--
Returns true if the given string is only whitespace.
@tparam string s String to check
@treturn bool True if the string consists of only whitespace
]]
function M.is_empty(s)
    return string.match(s, "%S") == nil
end

--[[--
Insert prefix before the first non-whitespace character in string.
@tparam string line String to which the prefix will be prepended
@tparam string prefix Prefix put at the beginning of the string
@treturn string String with prefix before first non-whitespace character
]]
function M.insert_at_beginning(line, prefix)
    -- If the line is empty, just return the prefix with any whitespace stipped
    if line == nil or line == '' then
        return M.trim(prefix)
    end
    local start_index = string.find(line, "%S")
    --[[ If there are no non-whitespace characters on the line,
    use 1 as a starting index ]]
    start_index = start_index == nil and 1 or start_index
    return string.sub(line, 0, start_index-1) .. prefix .. string.sub(line, start_index, #line)
end

--[[--
Insert prefix at index.
@tparam string line String to which the prefix will be prepended
@tparam string prefix Prefix that will be inserted at index
@tparam int index Where to insert the prefix
@treturn string String with prefix at index
]]
function M.insert_at_index(line, prefix, index)
    -- If the line is empty, just return the prefix with any whitespace stipped
    if M.is_empty(line) then
        return M.trim(prefix)
    end
    --[[ If the index is lower than 1 or nil, set it to 1 ]]
    index = index == nil and 1 or index
    index = index < 0 and 1 or index
    return string.sub(line, 0, index-1) .. prefix .. string.sub(line, index, #line)
end

--[[--
Get the index of the last occurence of a pattern in a string.
@tparam string str String to search for the pattern
@tparam string pattern Pattern to search for
@treturn int Index of the beginning of the last occurence of the pattern in the string
]]
function M.index_last_occurence(str, pattern)
    local result = 0
    local i = 0
    while true do
        i = string.find(str, pattern, i+1)
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
@tparam int start_index Where to start the gsub, inclusive
@treturn string Gsubbed string
]]
function M.gsub_from_index(str, pattern, replacement, count, start_index)
    -- The test if start_index-1 prevents duplicating chars when calling with 0
    local result = (start_index-1 > 0 and string.sub(str, 1, start_index-1) or '')
        .. string.gsub(string.sub(str, start_index, #str), pattern, replacement, count)
    return result
end

--[[--
Escape special characters in string
@tparam string text String to escape
@treturn string String with all special chars escaped
]]
function M.escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

--[[--
Basic enum functionality, kinda.
You can use it like this:
```lua
local new_enum = enum({"normal", "force_multi", "force_single"})
local mode = new_enum.force_single
if mode == new_enum.normal then
    print("In normal mode.")
end
```
@tparam {string,...} items The names of the available states
@treturn {{string,int},...} Table mapping each string to a number
]]
function M.enum(items)
    local table = {}
    for idx,val in ipairs(items) do
        table[val] = idx
    end
    return table
end


return M
