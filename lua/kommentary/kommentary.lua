local config = require("kommentary.config")

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function insert_at_beginning(line, prefix)
    return line:sub(0,0)..prefix..line:sub(1)
end

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

local function gsub_from_index(str, pattern, replacement, count, start_index)
    -- Start index is exlusive
    local result = string.sub(str, 1, start_index) .. string.gsub(string.sub(str, start_index+1, #str), pattern, replacement, count)
    return result
end

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

local function is_comment_single(line, comment_string)
    -- Since the line might be indented, trim all whitespace
    line = trim(line)
    return line:sub(1, #comment_string) == comment_string
end

-- Not properly tested yet, breaks when there is nothing on a beginning/end line
local function is_comment_multi(lines, comment_strings)
    if comment_strings == false then
        return false
    end
    -- Only the first and last lines are relevant, these may be the same
    local first_line = trim(lines[1])
    local last_line = trim(lines[#lines])
    local begins = first_line:sub(1, #comment_strings[1]) == comment_strings[1]
    local ends = last_line:sub(-#comment_strings[2]) == comment_strings[2]
    return begins and ends
end

local function is_comment(line_number_start, line_number_end)
    line_number_start = line_number_start-1
    -- Get the content of the range specififed, this will return a table of lines
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    -- Check whether the range is a single- or multiline range, get the appropriate comment_string
    if #content == 1 then
        local comment_string = config.get_single(0)
        if not comment_string == false then
            return is_comment_single(content[1], comment_string)
        else
            -- In case the language doesn't support single-line comments
            return is_comment_multi(content, comment_string)
        end
    elseif #content > 1 then
        local comment_string = config.get_multi(0)
        local result = is_comment_multi(content, comment_string)
        -- If the language doesn't support multiline comments, or
        -- if the lines are not a multiline comment,
        -- they might still be multiple single-line comments
        if not result then
            comment_string = config.get_single(0)
            for _, line in ipairs(content) do
                if not is_comment_single(line, comment_string) then
                    return false
                end
            end
            -- All of the lines are single-line comments
            return true
        else
            return result
        end
    else
        error("Empty range.")
    end
end

local function comment_in_line(line_number, comment_string)
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {insert_at_beginning(content, comment_string)})
end

local function comment_out_line(line_number, comment_string)
    -- Todo: indentation
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    if is_comment_single(content, comment_string) then
        local result, _ = string.gsub(content, comment_string, "", 1)
        vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {result})
    end
end

local function comment_in_range(line_number_start, line_number_end, comment_string)
    line_number_start = line_number_start-1
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    if comment_string == false then
        -- The language doesn't support multi-line comments, just loop over
        -- each line and comment it in with a single-line comment
        for line_number = line_number_start+1, line_number_end, 1 do
            comment_in_line(line_number, config.get_single(0))
        end
    else
        local result = {}
        if line_number_start == line_number_end then
            result = {insert_at_beginning(content, comment_string[1]) .. comment_string[2]}
        else
            result = {}
            for i, line in ipairs(content) do
                if i == 1 then
                    result[i] = insert_at_beginning(line, comment_string[1])
                else
                    result[i] = line
                end
            end
            result[#result] = result[#result] .. comment_string[2]
        end
        vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false, result)
    end
end

local function comment_out_range(line_number_start, line_number_end, comment_string)
    line_number_start = line_number_start-1
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    if comment_string == false then
        -- The language doesn't support multi-line comments, just loop over
        -- each line and comment it in with a single-line comment
        for line_number = line_number_start+1, line_number_end, 1 do
            comment_out_line(line_number, config.get_single(0))
        end
    else
        if is_comment_multi(content, comment_string) then
            local result = {}
            for i, line in ipairs(content) do
                local new_line = line
                if i == 1 then
                    new_line, _ = string.gsub(line, escape_pattern(comment_string[1]), "", 1)
                end
                if i == #content then
                    -- This will make sure that only the last occurence of the suffix is replaced
                    local start_index = index_last_occurence(line, comment_string[2])
                    new_line, _ = gsub_from_index(line, escape_pattern(comment_string[2]), "", 1, start_index)
                end
                result[i] = new_line
            end
            vim.api.nvim_buf_set_lines(0, line_number_start, line_number_end, false, result)
        end
    end
end

local function toggle_comment_line(line_number)
    local comment_string = config.get_single(0)
    if is_comment(line_number, line_number) then
        comment_out_line(line_number, comment_string)
    else
        comment_in_line(line_number, comment_string)
    end
end

local function toggle_comment_range(line_number_start, line_number_end)
    local comment_string = config.get_multi(0)
    if is_comment(line_number_start, line_number_end) then
        comment_out_range(line_number_start, line_number_end, comment_string)
    else
        comment_in_range(line_number_start, line_number_end, comment_string)
    end
end

return {
    is_comment_single = is_comment_single,
    is_comment_multi = is_comment_multi,
    is_comment = is_comment,
    comment_in_line = comment_in_line,
    comment_out_line = comment_out_line,
    comment_in_range = comment_in_range,
    comment_out_range = comment_out_range,
    toggle_comment_line = toggle_comment_line,
    toggle_comment_range = toggle_comment_range,
}
