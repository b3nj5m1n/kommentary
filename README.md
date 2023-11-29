# kommentary

Neovim plugin to comment text in and out, written in lua. Supports commenting out the current line, a visual selection and a motion.

![](https://web.archive.org/web/20220712113235/https://camo.githubusercontent.com/a91807453086b1616b6215875fbea95cd406d6a26c8c2bda8844f693a3cd9d18/68747470733a2f2f7331302e67696679752e636f6d2f696d616765732f5065656b2d323032312d30312d33302d32332d31322e676966)

## Note

Unfortunately, **I will not be adding any more features to kommentary**. I'll do my best to fix any problems, should they occur in the future.

There are several reasons for this decision, first and foremost, the codebase is really not fun to work on anymore and badly needs a rewrite. There are basically no unit tests, and some of the documentation is outdated. The whole structure is flawed, so implementing new features is a pain.

There's also a new plugin called [Comment.nvim](https://github.com/numToStr/Comment.nvim), it's also written entirely in lua, it seems to support everything kommentary supports, in addition to dot (`.`) repeat and operating on parts of a line instead of the whole line. It has significantly more contributors and seems to be actively developed. Sadly, this also seems to make kommentary obsolete.

Thanks to everyone who has contributed over the course of the last 2 years. ✌️

## Getting started

### Requirements

- Neovim 0.5+

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

The default keybindings are the same as in vim-commentary. That means you can toggle comments for the current line using gcc, for the current visual selection using gc, and in combination with a motion using gc, for example gc5j.

There's also some more advanced mappings which you can activate if you put this in your init.lua:

```lua
require('kommentary.config').use_extended_mappings()
```

The new mappings are:

* leader cic will increase commenting level for the current line, <leader>ci will do the same for a visual selection or motion
* leader cdc will decrease commenting level for the current line, <leader>di will do the same for a visual selection or motion

Which behind the scenes calls the following chunk of code, which you could also execute yourself with keybindings of your choice:
```lua
vim.api.nvim_set_keymap("n", "<leader>cic", "<Plug>kommentary_line_increase", {})
vim.api.nvim_set_keymap("n", "<leader>ci", "<Plug>kommentary_motion_increase", {})
vim.api.nvim_set_keymap("x", "<leader>ci", "<Plug>kommentary_visual_increase", {})
vim.api.nvim_set_keymap("n", "<leader>cdc", "<Plug>kommentary_line_decrease", {})
vim.api.nvim_set_keymap("n", "<leader>cd", "<Plug>kommentary_motion_decrease", {})
vim.api.nvim_set_keymap("x", "<leader>cd", "<Plug>kommentary_visual_decrease", {})
```

If you don't want to use the default mappings, you can disable the creation of those using the `kommentary_create_default_mappings` variable. Be sure to set the value *before* the plugin is loaded though.
```lua
vim.g.kommentary_create_default_mappings = false
```

You can then map those actions yourself (You might need to do that *after* the plugin is loaded), for example:
```lua
vim.api.nvim_set_keymap("n", "<leader>cc", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("n", "<leader>c", "<Plug>kommentary_motion_default", {})
vim.api.nvim_set_keymap("x", "<leader>c", "<Plug>kommentary_visual_default", {})
```

Originally, commenting in visual mode would not cancel the selection, after many requests this has been changed to the default behavior of vim-commentary. If you want the old behavior, disable the creation of the default mappings and then load the old ones:

```lua
vim.api.nvim_set_keymap("n", "gcc", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("n", "gc", "<Plug>kommentary_motion_default", {})
vim.api.nvim_set_keymap("v", "gc", "<Plug>kommentary_visual_default<C-c>", {})
```

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

If you set both of them to true, it will use the default.

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

### Configure multiple languages at once

Thanks to @pedro757, you can also set the same options for multiple languages by supplying a list of languages:

```lua
lua << EOF
require('kommentary.config').configure_language({"c", "rust"}, {
    prefer_single_line_comments = true,
})
EOF
```

### Advanced configuration

This plugin allows for very individual configuration, pretty much every operation the plugin does is broken up into smaller functions, all of which are exposed and can be called in a custom function, which you can easily assign to a mapping of your choice, meaning you can incorporate some of the functionality of this plugin into your own lua functions.
For more information, you can either read the source code (I do my best to leave helpful comments) or build the [documentation](README.md#Documentation).

Here is a simple example in which this plugin only plays a minor role, so it should be easy to understand (If you're a little familiar with neovim's lua api). We'll create mapping that, when called, inserts a new comment under the current line and puts us in insert mode.

```lua
local config = require('kommentary.config')
local M = {}

--[[ This function will be called automatically by the mapping, the first
argument will be the line that is being operated on. ]]
function M.insert_comment_below(...)
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
config.add_keymap("n", "kommentary_insert_below", config.context.line, { expr = true }, M.insert_comment_below)
-- Set up a regular keymapping to the new <Plug> mapping
vim.api.nvim_set_keymap('n', '<leader>co', '<Plug>kommentary_insert_below', { silent = true })

return M
```


## Contributing

Any and all contributions are greatly appreciated!

### Issues

If you found a bug or want to request a feature, pleases do so by [raising an issue](https://github.com/b3nj5m1n/kommentary/issues/new/choose).

### Pull Requests

1. Fork the Project
2. Create your Feature Branch (`git checkout -b amazing_feature`)
3. Make your changes
4. Commit your Changes (`git commit -m 'Add some amazing feature'`)
5. Push to the Branch (`git push origin amazing_feature`)
6. Open a Pull Request

Please try your best to follow the style of the rest of the codebase, even though there's no official spec or linter for
it. (Try not to exceed 80 characters per line, use snake_case)

### Documentation

The code is heavily commented, functions are documented using [LDoc](https://github.com/lunarmodules/LDoc).

You can build the documentation with this command:
```
ldoc .
```
Then you can access it from doc/index.html

### Tests

Thanks to @YodaEmbedding, there are now proper unit tests available.

Make sure [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) is installed, then navigate to the lua directory.

From here, you can run the tests with the following command:

```bash
nvim --headless -c "PlenaryBustedDirectory test/"
```
