local config = require("config")

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function is_comment_single(line, comment_string)
    -- Since the line might be indented, trim all whitespace
    line = trim(line)
    return line:sub(1, #comment_string) == comment_string
end

local function is_comment_multi(lines, comment_string)

end

local function is_comment(line_number_start, line_number_end)
    -- Get the content of the range specififed, this will return a table of lines
    local content = vim.api.nvim_buf_get_lines(0, line_number_start, line_number_end, false)
    -- Check whether the range is a single- or multiline range, get the appropriate comment_string
    if #content == 1 then
        local comment_string = config.get_single(0)
        return is_comment_single(content[1], comment_string)
    elseif #content > 1 then
        local comment_string = config.get_multi(0)
        local result = is_comment_multi(content, comment_string)
        -- If the lines are not a multiline comment, they might still be multiple single-line comments
        if not result then
            local comment_string = config.get_single(0)
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

-- local function comment_in_line()
--
-- end
--
-- local function comment_out_line()
--
-- end
--
-- local function comment_in_range()
--
-- end
--
-- local function comment_out_range()
--
-- end

return {
    is_comment_single = is_comment_single,
    is_comment_multi = is_comment_multi,
    is_comment = is_comment,
}
