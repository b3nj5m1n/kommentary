local lu = require('luaunit')
local config = require('kommentary.config')

Test_Config = {}

function Test_Config.test_has_filetype()
    lu.assertEquals(config.has_filetype("lua"), true)
    lu.assertEquals(config.has_filetype("FCnDFBIVgiefEKWafTbf"), false)
    lu.assertEquals(config.has_filetype("hIJtMRKoOTDbgrNqywPv"), false)
    config.config["hIJtMRKoOTDbgrNqywPv"] = {"//", false}
    lu.assertEquals(config.has_filetype("hIJtMRKoOTDbgrNqywPv"), true)
    lu.assertEquals(config.has_filetype(""), false)
end

function Test_Config.test_config_from_commentstring()
    lu.assertEquals(config.config_from_commentstring("--%s"), {"--", false})
    lu.assertEquals(config.config_from_commentstring("<!--%s-->"), {false, {"<!--", "-->"}})
    lu.assertEquals(config.config_from_commentstring("!%s"), {"!", false})
    lu.assertEquals(config.config_from_commentstring(""), {"//", {"/*", "*/"}})
end

function Test_Config.test_get_config()
    lu.assertEquals(config.get_config("python"), {"#", false})
    lu.assertEquals(config.get_config("markdown"), {false, {"<!---", "-->"}})
    lu.assertEquals(config.get_config("rust"), {"//", {"/*", "*/"}})
end

function Test_Config.test_get_single()
    lu.assertEquals(config.get_single("python"), "#")
    lu.assertEquals(config.get_single("markdown"), false)
    lu.assertEquals(config.get_single("rust"), "//")
end

function Test_Config.test_get_multi()
    lu.assertEquals(config.get_multi("python"), false)
    lu.assertEquals(config.get_multi("markdown"), {"<!---", "-->"})
    lu.assertEquals(config.get_multi("rust"), {"/*", "*/"})
end

function Test_Config.test_get_modes()
    lu.assertItemsEquals(config.get_modes(), {normal=1, force_multi=2, force_single=3})
end

os.exit( lu.LuaUnit.run() )
