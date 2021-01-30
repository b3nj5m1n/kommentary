
--[[ Configuration for each filetype, the first field is the prefix for a single
line comment, the second field is either false, if multi-line comments aren't
supported by that filetype, or a table where the first field is the prefix
for a multi-line comment and the second field is the suffix. Note that the very
first field can also be false, if a language always requires a pre- and suffix.
]]
local config_table = {
    ["lua"] = {"-- ", {"--[[ ", " ]]"}},
    ["markdown"] = {false, {"<!--- ", " -->"}},
}

local function get_single(filetype)
    if filetype == 0 then
        filetype = vim.bo.filetype
    end
    return config_table[filetype][1]
end

local function get_multi(filetype)
    if filetype == 0 then
        filetype = vim.bo.filetype
    end
    return config_table[filetype][2]
end

return {
    config = config_table,
    get_single = get_single,
    get_multi = get_multi,
}
