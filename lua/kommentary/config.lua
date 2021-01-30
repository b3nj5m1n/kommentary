local default = {"// ", {"/* ", " */"}}

--[[ Configuration for each filetype, the first field is the prefix for a single
line comment, the second field is either false, if multi-line comments aren't
supported by that filetype, or a table where the first field is the prefix
for a multi-line comment and the second field is the suffix. Note that the very
first field can also be false, if a language always requires a pre- and suffix.
Newlines are not allowed, since they can't be matched when commenting out.
]]
local config_table = {
    ["c"] = default,
    ["cpp"] = default,
    ["cs"] = default,
    ["go"] = default,
    ["java"] = default,
    ["javascript"] = default,
    ["kotlin"] = default,
    ["lua"] = {"-- ", {"--[[ ", " ]]"}},
    ["markdown"] = {false, {"<!--- ", " -->"}},
    ["python"] = {"# ", false},
    ["r"] = {"# ", false},
    ["ruby"] = {"# ", false},
    ["rust"] = default,
    ["swift"] = default,
    ["vim"] = {"\" ", false},
}

local function has_filetype(filetype)
    return config_table[filetype] ~= nil
end

local function get_config(filetype)
    if filetype == 0 then
        filetype = vim.bo.filetype
    end
    if not has_filetype(filetype) then
        return default
    end
    return config_table[filetype]
end

local function get_single(filetype)
    return get_config(filetype)[1]
end

local function get_multi(filetype)
    return get_config(filetype)[2]
end

return {
    config = config_table,
    get_single = get_single,
    get_multi = get_multi,
}
