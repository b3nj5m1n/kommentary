# kommentary

Neovim plugin to comment text in and out, written in lua. Supports commenting out the current line, a visual selection and a motion/textobject.

![](https://s2.gifyu.com/images/Peek-2021-01-30-23-12.gif)

## Getting started

### Install

You can install the plugin using your favorite plugin manager, just make sure you remove any plugins that might conflict with this one, such as vim-commentary.

#### Packer

```lua
use 'b3nj5m1n/kommentary'
```

#### Vim-Plug

```viml
Plug 'b3nj5m1n/kommentary'
```

### Default Keybindings

The default keybindings are the same as in vim-commentary. That means you an toggle comments for the current line using gcc, for the current visual selection using gc, and in combination with a motion using gc, for example gc5j.

There's also some more advanced mappings:

* leader cic will increase commenting level for the current line, <leader>ci will do the same for a visual selection or motion
* leader cdc will decrease commenting level for the current line, <leader>di will do the same for a visual selection or motion

## Configuration

For most users, configuration should hardly be necessary, I try to provide sane defaults and the plugin, once installed, can basically be used as a drop-in replacement for vim-commentary. That being said, maybe you have some different preferences, or you like your editor heavily customised, this plugin should still have you covered.

The config module provides a convenience function called `configure_language` which makes it easy to configure a language.

### Configure unsupported language

Most languages have basic support out of the box, thanks to `commentstring`.
Unfortunately however, for some languages `commentstring` is not set.
Also, `commentstring` supports either single-line or multi-line comments, not both.
For those reasons, you might prefer to properly configure a language. You can do it like this:

```lua
lua << EOF
require('kommentary.config').configure_language("rust", {
    single_line_comment_string = "//",
    multi_line_comment_strings = {"/*", "*/"},
})
EOF
```

If one of those two is not supported by the language, set the value to false, otherwise the default (`//` for single-line and `{/*,*/}` for multi-line) will be used.

### Always use single/multi-line comments

Some languages might technically support multi-line comments but have some quirks with them, or maybe you just prefer single-line comments. The proper way to configure this is:

```lua
lua << EOF
require('kommentary.config').configure_language("rust", {
    prefer_single_line_comments = true,
})
EOF
```

It also works the other way:

```lua
lua << EOF
require('kommentary.config').configure_language("rust", {
    prefer_multi_line_comments = true,
})
EOF
```

If you set both of the to true, it will use the default.

You can also set global defaults, these will be used for all languages, unless you overwrite it for that specific language like shown above:
```lua
lua << EOF
require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})
EOF
```

### More configuration options

The `configure_language` provides access to two other options, `use_consistent_indentation` and `ignore_whitespace`. Both are set to true by default, but of course you can overwrite that. 

#### `use_consistent_indentation`

`use_consistent_indentation` will cause blocks commented in with `prefer_single_line_comments` enabled to all have the comment prefix in the same column:

```lua
-- local function example()
--    print("Example")
-- end
```
Instead of
```lua
-- local function example()
    -- print("Example")
-- end
```

#### `ignore_whitespace`

`ignore_whitespace` will cause lines that don't contain anything to be ignored, it's as simple as that.

```lua
-- function test_function_1()
--     print("test")
-- end

-- function test_function_2()
--     print("test")
-- end
```
Instead of
```lua
-- function test_function_1()
--     print("test")
-- end
-- 
-- function test_function_2()
--     print("test")
-- end
```

### Advanced configuration

This plugin allows for very individual configuration, pretty much every operation the plugin does is broken up into smaller functions, all of which are exposed and can be called in a custom function, which you can easily assign to a mapping of your choice, meaning you can incorporate the some of the functionality of this plugin into your own lua functions.
For more information, you can either read the source code (I do my best to leave helpful comments) or build the documentation.

Here is a simple example in which this plugin only plays a minor role, so it should be easy to understand (If you're a little familiar with neovim's lua api). We'll create mapping that, when called, inserts a new comment under the current line and puts us in insert mode.

```lua
local config = require('kommentary.config')

--[[ This function will be called automatically by the mapping, the first
argument will be the line that is being operated on. ]]
function insert_comment_below(...)
    local args = {...}
    -- This includes the commentstring
    local configuration = config.get_config(0)
    local line_number = args[1]
    -- Get the current content of the line
    local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    --[[ Get the level of indentation of that line (Find the index of the
    first non-whitespace character) ]]
    local indentation = string.find(content, "%S")
    --[[ Create a string with that indentation, with a dot at the end so that
    kommentary respects that indentation ]]
    local new_line = string.rep(" ", indentation-1) .. "."
    -- Insert the new line underneath the current one
    vim.api.nvim_buf_set_lines(0, line_number, line_number, false, {new_line})
    -- Comment in the new line
    require('kommentary.kommentary').comment_in_line(line_number+1, configuration)
    -- Set the cursor to the correct position
    vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1]+1, #new_line+2})
    -- Change the char under cursor (.)
    vim.api.nvim_feedkeys("cl", "n", false)
end

--[[ This is a method provided by kommentary's config, it will take care of
setting up a <Plug> mapping. The last argument is the optional callback
function, meaning when we execute this mapping, this function will be
called instead of the default. --]]
config.add_keymap("n", "kommentary_insert_below", config.context.line, {}, "insert_comment_below")
-- Set up a regular keymapping to the new <Plug> mapping
vim.api.nvim_set_keymap('n', '<leader>co', '<Plug>kommentary_insert_below', { silent = true })
```


## Contributing

Any and all contributions are greatly appreciated!

### Issues

If you found a bug or want to request a feature, pleases do so by [raising an issue](https://github.com/b3nj5m1n/kommentary/issues/new/choose).

### Pull Requests

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the Branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

Please try your best to follow the style of the rest of the codebase, even though there's no official spec or linter for it.

### Documentation

The code is heavily commented, functions are documented using [LDoc](https://github.com/lunarmodules/LDoc).

You can build the documentation with this command:
```
ldoc .
```
Then you can access it from doc/index.html

### Tests

There are unit tests available in the directory `lua/test`, you'll need to have [luaunit](https://github.com/bluebird75/luaunit) installed, then run:
```sh
cd ./lua/
lua test/test_util.lua

# You might need to specify the lua version because luaunit doesn't support the latest ones
# lua5.3 test/test_util.lua

# For verbose output (Which tests are being run)
# lua test/test_util.lua -v
```

Or to run all tests:
```sh
cd ./lua/
./run_tests.sh
```
