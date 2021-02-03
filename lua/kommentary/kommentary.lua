--[[--
Functions for commenting code in and out.

This module contains the functions for commenting lines/ranges
in/out/toggeling and detecting comments.
@module kommentary.kommentary
]]
local config = require("kommentary.config")
local util = require("kommentary.util")
local M = {}

--[[--
Check if a string is a single-line comment.
@tparam string line A single line string
@tparam string comment_string The prefix of a single-line comment
@treturn bool true if it is a single-line comment, otherwise false
]]
function M.is_comment_single(line, configuration)
    -- Since the line might be indented, trim all whitespace
    local comment_string = configuration[1]
    line = util.trim(line)
    return line:sub(1, #comment_string) == comment_string
end

--[[--
Check if a string is a multi-line comment.
@tparam {string,...} lines A table of lines
@tparam {string,string} comment_strings A tuple containing the prefix and
        suffix of a multi-line comment
@treturn bool true if it is a multi-line comment, otherwise false
]]
function M.is_comment_multi(lines, configuration)
    local comment_strings = configuration[2]
    if comment_strings == false or #lines < 1 then
        return false
    end
    -- Only the first and last lines are relevant, these may be the same
    local first_line = util.trim(lines[1])
    local last_line = util.trim(lines[#lines])
    local begins = first_line:sub(1, #comment_strings[1]) == comment_strings[1]
    local ends = last_line:sub(-#comment_strings[2]) == comment_strings[2]
    return begins and ends
end

--[[--
Check if a string is a range of single-line comments.
@tparam {string,...} lines A table of lines
@tparam string comment_string The prefix of a single-line comment
@treturn bool true if it is a range of single-line comments
]]
function M.is_comment_multi_single(lines, configuration)
    local comment_string = configuration[1]
    if comment_string == false or #lines < 1 then
        return false
    end
    for _, line in ipairs(lines) do
        if not M.is_comment_single(line, configuration) then
            if not util.is_empty(line) then
                return false
            end
        end
    end
    -- All of the lines are single-line comments
    return true
end

--[[--
Checks if the specified range in the buffer is a comment.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@treturn bool true if it is a multi-line comment, otherwise false
]]
function M.is_comment(line_number_start, line_number_end, configuration)
    line_number_start = line_number_start-1
    local result = nil
    -- Get the content of the range specififed, this will return a table of lines
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    -- Check whether the range is a single- or multiline range, get the appropriate comment_string
    local comment_string = nil
    if #content == 1 then
        comment_string = configuration[1]
        if not comment_string == false then
            result = M.is_comment_single(content[1], configuration)
        end
        if not result == true then
            -- In case the language doesn't support single-line comments
            comment_string = configuration[2]
            result = M.is_comment_multi(content, configuration)
        end
    elseif #content > 1 then
        comment_string = configuration[2]
        result = M.is_comment_multi(content, configuration)
        -- If the language doesn't support multiline comments, or
        -- if the lines are not a multiline comment,
        -- they might still be multiple single-line comments
        if not result == true then
            comment_string = configuration[1]
            if not comment_string == false then
                result = M.is_comment_multi_single(content, configuration)
            end
        end
    else
        error("Empty range.")
    end
    return result
end

--[[--
Turns the line into a single-line comment.
@tparam int line_number Line to operate on
@tparam string comment_string The prefix of a single-line comment
@treturn nil
]]
function M.comment_in_line(line_number, configuration)
    local comment_string = configuration[1]
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {util.insert_at_beginning(content, comment_string .. " ")})
end

--[[--
Turns the line, a single-line comment, into normal code.
This might not turn the line into normal code, if the line has been commented out
multiple times, for example in lua: `-- -- This has been commented out 2 times`,
in which case it will remove one *level* of comments, so in this example it will
turn into:  `-- This has been commented out 2 times`.
@tparam int line_number Line to operate on
@tparam string comment_string The prefix of a single-line comment
@treturn nil
]]
function M.comment_out_line(line_number, configuration)
    local comment_string = configuration[1]
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    if M.is_comment_single(content, configuration) then
        local result, _ = string.gsub(content, util.escape_pattern(comment_string) .. "%s*", "", 1)
        vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {result})
    end
end

--[[--
Turns the range into multiple single-line comments.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@tparam string comment_string The prefix of a single-line comment
@treturn nil
]]
function M.comment_in_range_single(line_number_start, line_number_end, configuration)
    line_number_start = line_number_start-1
    local comment_string = configuration[1]
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    --[[ This function will return the index at which to insert the comment prefix.
    in the current state, this function will return the index of the first
    non-whitespace character, if the option for consistend indentation is set,
    it will later be overwritten to return a constant number (the lowest
    index at which to insert indentation) ]]
    local comment_index = function(line) return string.find(line, "%S") end
    local result = {}
    -- This is the flag for using consistend indentation
    if configuration[5] == true then
        --[[ This is the variable for keeping track of the lowest index we find,
        initially we set it to -1, then loop over all lines until we find one
        that is not empty, then set this variable to the length of that line.
        This means that empty lines will not factor in to where the indentation
        starts. ]]
        local lowest_index = -1
        for i = 1, #content, 1 do
            lowest_index = #content[i]
            if lowest_index > 0 then break end
        end
        --[[ Loop over all lines, get the index of the first non-whitespace char,
        if that is lower then the current lowest_index, set it as the new
        lowest_index. ]]
        for _, line in ipairs(content) do
            local index = string.find(line, "%S")
            if index ~= nil and index < lowest_index then
                lowest_index = index
            end
        end
        -- Set the comment_index function to return a constant value.
        comment_index = function(line) return lowest_index end
    end
    -- Loop over all lines, insert the prefix at the previously set index.
    for _, line in ipairs(content) do
        --[[ Check if ignore_whitespace is set, if so, and the line is consists
        of only whitespace, insert it back into result as-is. ]]
        if configuration[6] == true and util.is_empty(line) == true then
            table.insert(result, line)
        else
            table.insert(result, util.insert_at_index(line, comment_string .. " ",
                comment_index(line)))
        end
    end
    vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false,
        result)
end

--[[--
Turns the range into a multi-line comment.
If the language doesn't support multi-line comments, it will turn the range
into multiple single-line comments instead.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@tparam {string,string} comment_string A tuple containing the prefix and
        suffix of a multi-line comment
@treturn nil
]]
function M.comment_in_range(line_number_start, line_number_end, configuration)
    line_number_start = line_number_start-1
    local comment_strings = configuration[2]
    local content = vim.api.nvim_buf_get_lines(0, line_number_start,
        line_number_end, false)
    if comment_strings == false then
        -- The language doesn't support multi-line comments
        M.comment_in_range_single(line_number_start, line_number_end, configuration)
    else
        local result = {}
        if line_number_start == line_number_end then
            result = {util.insert_at_beginning(content, comment_strings[1] .. " ")
                .. " " .. comment_strings[2]}
        else
            result = {}
            for i, line in ipairs(content) do
                if i == 1 then
                    result[i] = util.insert_at_beginning(line,
                        comment_strings[1] .. " ")
                else
                    result[i] = line
                end
            end
            result[#result] = result[#result] .. " " .. comment_strings[2]
        end
        vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false,
            result)
    end
end

--[[--
Turns the range, multiple single-line comments, into normal code.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@tparam string comment_string The prefix of a single-line comment
@treturn nil
]]
function M.comment_out_range_single(line_number_start, line_number_end, configuration)
    line_number_start = line_number_start-1
    local comment_string = configuration[1]
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    local result = {}
    for _, line in ipairs(content) do
        local new_line, _ = string.gsub(line, util.escape_pattern(comment_string) .. "%s?", "", 1)
        table.insert(result, new_line)
    end
    vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false, result)
end

--[[--
Turns the range, a multi-line comment, into normal code.
If the language doesn't support multi-line comments, it will comment out each
single line comment individually.
Just as with commenting out a single line, this might not make the range into
normal code, but remove one *level* of commenting instead.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@tparam {string,string} comment_string A tuple containing the prefix and
        suffix of a multi-line comment
@treturn nil
@see comment_out_line
]]
function M.comment_out_range(line_number_start, line_number_end, configuration)
    line_number_start = line_number_start-1
    local comment_strings = configuration[2]
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    -- If the range consists of multiple single-line comments
    local single_comments_array = comment_strings == false
    if not single_comments_array then
        if M.is_comment_multi(content, configuration) then
            local result = {}
            for i, line in ipairs(content) do
                local new_line = line
                if i == 1 then
                    new_line, _ = string.gsub(new_line, util.escape_pattern(comment_strings[1]) .. "%s*", "", 1)
                end
                if i == #content then
                    -- This will make sure that only the last occurence of the suffix is replaced
                    local start_index = util.index_last_occurence(new_line, util.escape_pattern(comment_strings[2]))
                    new_line, _ = util.gsub_from_index(new_line, "%s*" .. util.escape_pattern(comment_strings[2]), "", 1, start_index-1)
                end
                result[i] = new_line
            end
            vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false, result)
        else
            single_comments_array = true
        end
    end
    if single_comments_array then
        --[[ The language doesn't support multi-line comments, or the
        range just doesn't use them. Because comment_out_range_single
        also subracts one from the line_number_start, we have to add it
        back here as to not end up with a subraction of 2 ]]
        M.comment_out_range_single(line_number_start+1, line_number_end, configuration)
    end
end

--[[--
Toggles commenting on the line.
This function will automatically resolve the proper comment_string for the
current buffer.
If the line is commented out multiple times, it will first remove all starting
comments before starting to toggle comments, so for example in lua:
`-- -- -- Test` would first become `-- -- Test`, then  `-- Test`, then finally
`Test` and from then on alternate between that and `-- Test`.
@tparam int line_number Line to operate on
@tparam string mode State in enum (Defined by config), available states are:
        - normal: This is the default, behave normally
        - force_multi: Force the use of multi-line comment syntax (Prefix and Suffix)
            regardless of how many lines are being operated on
        - force_single: Force the use of single-line comment syntax (Prefix only)
            regardless of how many lines are being operated on
        All of these only have an effect when commenting in
@treturn nil
]]
function M.toggle_comment_line(line_number, mode)
    local configuration = config.get_config(0)
    local comment_string = configuration[1]
    local modes = config.get_modes()
    -- No specfic mode requested, so it can be changed
    if mode == modes.normal then
        -- If the language doesn't support single-line comments
        if comment_string == false then
            mode = modes.force_multi
        end
    end
    if M.is_comment(line_number, line_number, configuration) then
        if mode == modes.force_multi then
            M.comment_out_range(line_number, line_number, configuration)
        else
            M.comment_out_line(line_number, configuration)
        end
    else
        if mode == modes.force_multi then
            M.comment_in_range(line_number, line_number, config.get_multi(0))
        else
            M.comment_in_line(line_number, comment_string)
        end
    end
end

--[[--
Toggles commenting on the range.
Behaves the same way as toggeling a single line.
@tparam int line_number_start Start of the range, inclusive
@tparam int line_number_end End of the range, inclusive
@tparam string mode State in enum (Defined by config), available states are:
        - normal: This is the default, behave normally
        - force_multi: Force the use of multi-line comment syntax (Prefix and Suffix)
            regardless of how many lines are being operated on
        - force_single: Force the use of single-line comment syntax (Prefix only)
            regardless of how many lines are being operated on
        All of these only have an effect when commenting in
@treturn nil
@see toggle_comment_line
]]
function M.toggle_comment_range(line_number_start, line_number_end, mode)
    --[[ If you start a selection and then move up, it would be detected
    as a negative range, so if that's the case swap the start and end. ]]
    if line_number_end < line_number_start then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    local configuration = config.get_config(0)
    local modes = config.get_modes()
    mode = config.get_mode(line_number_start, line_number_end, mode)
    if M.is_comment(line_number_start, line_number_end, configuration) then
        M.comment_out_range(line_number_start, line_number_end, configuration)
    else
        if mode == modes.force_single then
            M.comment_in_range_single(line_number_start, line_number_end, configuration)
        else
            M.comment_in_range(line_number_start, line_number_end, configuration)
        end
    end
end

return M
