local config = require("kommentary.config")
local kommentary = require("kommentary.kommentary")

local function toggle_comment()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    kommentary.toggle_comment_line(row)
end

local function test()
    print(config.get_single(0))
end

return {
    toggle_comment = toggle_comment,
    test = test,
}
