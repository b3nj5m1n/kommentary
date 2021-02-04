local lu = require('luaunit')
local util = require('kommentary.util')

Test_Util = {}

function Test_Util.test_is_empty()
    lu.assertEquals(util.is_empty('  test'), false)
    lu.assertEquals(util.is_empty('  '), true)
    lu.assertEquals(util.is_empty('	'), true)
    lu.assertEquals(util.is_empty('	  '), true)
end

function Test_Util.test_insert_at_beginning()
    lu.assertEquals(util.insert_at_beginning('test', '// '), '// test')
    lu.assertEquals(util.insert_at_beginning('test', '//'), '//test')
    lu.assertEquals(util.insert_at_beginning('    test', '// '), '    // test')
    lu.assertEquals(util.insert_at_beginning('	test', '// '), '	// test')
    lu.assertEquals(util.insert_at_beginning('    test with multiple words', '// '), '    // test with multiple words')
    lu.assertEquals(util.insert_at_beginning('test', '-- '), '-- test')
    lu.assertEquals(util.insert_at_beginning('test', '# '), '# test')
    lu.assertEquals(util.insert_at_beginning('test', '! '), '! test')
    lu.assertEquals(util.insert_at_beginning('test', '	§s!!!+#12235    '), '	§s!!!+#12235    test')
    lu.assertEquals(util.insert_at_beginning('    ', '// '), '//     ')
end

function Test_Util.test_insert_at_index()
    lu.assertEquals(util.insert_at_index('test', '// ', 1), '// test')
    lu.assertEquals(util.insert_at_index('test', '// ', 3), 'te// st')
    lu.assertEquals(util.insert_at_index('', '// ', 1), 't// ')
end

function Test_Util.test_index_last_occurence()
    lu.assertEquals(util.index_last_occurence('test test test test', 'test'), 16)
    lu.assertEquals(util.index_last_occurence('/* This is what this */ function would be used for */', '*/'), 52)
    lu.assertEquals(util.index_last_occurence('<!--- This is what this --> function would be used for -->', util.escape_pattern('-->')), 56)
    lu.assertEquals(util.index_last_occurence('', 'test'), 0)
    lu.assertEquals(util.index_last_occurence('test', ''), 5)
end

function Test_Util.test_gsub_from_index()
    lu.assertEquals(util.gsub_from_index('test test test test', 'test', 'is this thing on?', 1, 15), 'test test test is this thing on?')
    lu.assertEquals(util.gsub_from_index('/* This is what this */ function would be used for */', '*/', '', 1, 52), '/* This is what this */ function would be used for ')
    lu.assertEquals(util.gsub_from_index('a', '*/', 'test', 1, 0), 'a')
    lu.assertEquals(util.gsub_from_index('', '*/', 'test', 1, 0), '')
    lu.assertEquals(util.gsub_from_index('test', 'test', '', 1, 2), 'test')
    lu.assertEquals(util.gsub_from_index('test', 'test', '', 1, 1), '')
    lu.assertEquals(util.gsub_from_index('test', 'test', '', 1, 0), '')
    lu.assertEquals(util.gsub_from_index('test test test', 'test', 'tset', 2, 5), 'test tset tset')
    lu.assertEquals(util.gsub_from_index('', 'test', '', 1, 0), '')
    lu.assertEquals(util.gsub_from_index('test', '', '', 1, 0), 'test')
end

function Test_Util.test_enum()
    local enum = util.enum({"normal", "force_multi", "force_single"})
    lu.assertItemsEquals(enum, {normal=1, force_multi=2, force_single=3})
    local mode = enum.normal
    lu.assertEquals(mode, 1)
    lu.assertEquals(mode, enum.normal)
    mode = enum.force_multi
    lu.assertEquals(mode, 2)
    lu.assertEquals(mode, enum.force_multi)
    mode = enum.force_single
    lu.assertEquals(mode, 3)
    lu.assertEquals(mode, enum.force_single)
    mode = enum.normal
    mode = mode + 1
    lu.assertEquals(mode, 2)
    lu.assertEquals(mode, enum.force_multi)
end

os.exit( lu.LuaUnit.run() )
