
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

return {
    trim = trim,
    insert_at_beginning = insert_at_beginning,
    index_last_occurence = index_last_occurence,
    gsub_from_index = gsub_from_index,
    escape_pattern = escape_pattern,
}
