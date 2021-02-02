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
    lu.assertEquals(config.config_from_commentstring("--%s"), {"--", false, false, false, true})
    lu.assertEquals(config.config_from_commentstring("# %s"), {"#", false, false, false, true})
    lu.assertEquals(config.config_from_commentstring("<!--%s-->"), {false, {"<!--", "-->"}, false, false, true})
    lu.assertEquals(config.config_from_commentstring("!%s"), {"!", false, false, false, true})
    lu.assertEquals(config.config_from_commentstring(""), {"//", {"/*", "*/"}, false, false, true})
end

function Test_Config.test_get_default_mode()
    lu.assertEquals(config.get_default_mode("rust"), 1)
end

function Test_Config.test_get_config()
    lu.assertEquals(config.get_config("fennel"), {";", false, false, false, true})
    lu.assertEquals(config.get_config("rust"), {"//", {"/*", "*/"}, false, false, true})
end

function Test_Config.test_get_single()
    lu.assertEquals(config.get_single("fennel"), ";")
    lu.assertEquals(config.get_single("rust"), "//")
end

function Test_Config.test_get_multi()
    lu.assertEquals(config.get_multi("fennel"), false)
    lu.assertEquals(config.get_multi("rust"), {"/*", "*/"})
end

function Test_Config.test_get_modes()
    lu.assertItemsEquals(config.get_modes(), {normal=1, force_multi=2, force_single=3})
end

os.exit( lu.LuaUnit.run() )
