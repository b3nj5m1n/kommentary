
local lu = require('luaunit')
local kommentary = require('kommentary.kommentary')

Test_Kommentary = {}

function Test_Kommentary.test_is_comment_single()
    lu.assertItemsEquals(kommentary.is_comment_single("    -- This is an example", "--"), true)
    lu.assertItemsEquals(kommentary.is_comment_single("", "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_single("-- This is an example", ""), true)
    lu.assertItemsEquals(kommentary.is_comment_single("-- This is an example", "-"), true)
    lu.assertItemsEquals(kommentary.is_comment_single("-- This is an example", "--"), true)
    lu.assertItemsEquals(kommentary.is_comment_single("-- This is an example", "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_single("/ / This is a test", "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_single("//This is a test", "//"), true)
end

function Test_Kommentary.test_is_comment_multi()
    lu.assertItemsEquals(kommentary.is_comment_multi({"", ""}, {"/*", "*/"}), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({""}, {"/*", "*/"}), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({"--[[ This is an example ]]"}, {"--[[", "]]"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is */", "an example */"}, {"/*", "*/"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is */", "an example"}, {"/*", "*/"}), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is */", "another", "example */"}, {"/*", "*/"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is */", "another", "example"}, {"/*", "*/"}), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is an example */"}, {"/*", "*/"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is test */"}, false), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is", "an example */"}, {"/*", "*/"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({"/* This is", "another", "example */"}, {"/*", "*/"}), true)
    lu.assertItemsEquals(kommentary.is_comment_multi({}, false), false)
    lu.assertItemsEquals(kommentary.is_comment_multi({}, {"/*", "*/"}), false)
end

function Test_Kommentary.test_is_comment_multi_single()
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"", ""}, "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({""}, "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"-- This is an example"}, "--"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is */", "//an example */"}, "//"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is */", "/an example"}, "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is */", "//another", "// example */"}, "//"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is */", "another", "// example"}, "//"), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is an example"}, "//"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is test"}, false), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is", "// an example"}, "//"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({"// This is", "// another", "// example"}, "//"), true)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({}, false), false)
    lu.assertItemsEquals(kommentary.is_comment_multi_single({}, "//"), false)
end

os.exit( lu.LuaUnit.run() )
