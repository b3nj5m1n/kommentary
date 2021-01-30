local config = require("config")

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function insert_at_beginning(line, prefix)
    return line:sub(0,0)..prefix..line:sub(1)
end

local function is_comment_single(line, comment_string)
    -- Since the line might be indented, trim all whitespace
    line = trim(line)
    return line:sub(1, #comment_string) == comment_string
end

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Not properly tested yet
local function is_comment_multi(lines, comment_strings)
    -- Only the first and last lines are relevant, these may be the same
    local first_line = trim(lines[1])
    local last_line = trim(lines[#lines])
    local begins = first_line:sub(1, #comment_strings[1]) == comment_strings[1]
    local ends = last_line:sub(-#comment_strings[2]) == comment_strings[2]
    return begins and ends
end

local function is_comment(line_number_start, line_number_end)
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

-- local function comment_in_range(line_number_start, line_number_end)
--     -- nvim_buf_set_lines({buffer}, {start}, {end}, {strict_indexing}, {replacement})
--     local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
--     local comment_string = config.get_single(0)
--     vim.api.buf_set_lines(0,line_number_start, line_number_end, false, )
-- end

-- local function comment_out_range(line_number_start, line_number_end)

-- end

local function comment_in_line(line_number, comment_string)
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {insert_at_beginning(content, comment_string)})
end

local function comment_out_line(line_number, comment_string)
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    if is_comment_single(content, comment_string) then
        local result, _ = string.gsub(content, comment_string, "", 1)
        vim.api.nvim_buf_set_lines(0, line_number-1, line_number, false, {result})
    end
end

local function toggle_comment_line(line_number)
    local comment_string = config.get_single(0)
    if is_comment(line_number-1, line_number) then
        comment_out_line(line_number, comment_string)
    else
        comment_in_line(line_number, comment_string)
    end
end

return {
    is_comment_single = is_comment_single,
    is_comment_multi = is_comment_multi,
    is_comment = is_comment,
    comment_in_line = comment_in_line,
    comment_out_line = comment_out_line,
    toggle_comment_line = toggle_comment_line,
}
