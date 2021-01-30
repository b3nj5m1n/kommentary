local config = require("kommentary.config")

local function toggle_comment()
    print "Not yet implemented."
end

local function test()
    print(config.get_single(0))
end

return {
    toggle_comment = toggle_comment,
    test = test,
}
