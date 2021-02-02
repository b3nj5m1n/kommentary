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

## Configuration

The config module provides a convenience function called `configure_language` which makes it easy to configure a language.

### Configure unsupported language

Most languages have basic support out of the box, thanks to `commentstring`, however for some languages `commentstring` is not set, and `commentstring` supports either single-line or multi-line comments, not both.
For those reasons, you might prefer to properly configure a language. You can do it like this:

```lua
lua << EOF
require('kommentary.config').configure_language("rust", {
    single_line_comment = "//",
    multi_line_comment = {"/*", "*/"},
})
EOF
```

If one of those two is not supported by the language, set the value to false, otherwise the default (`//` for single-line and `{/*,*/}` for multi-line) will be used.

### Always use single/multi-line comments

Some languages might technically support multi-line comments but have some quirks with them, or maybe you just prefer single-line comments. The easy way to configure this is:

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

Please note that this is considered advise to the plugin, so there are cases in which multi-line comments will be used, for example if the multi-line comment string is set to false. You shouldn't worry about this, since you shouldn't encounter it during normal use.

If you wish to completely disable any of these two, under all circumstances (Again, this shouldn't be necessary), you can simply set the multi-line comment string to false:

```lua
lua << EOF
require('kommentary.config').configure_language("rust", {
    single_line_comment = "//",
    multi_line_comment = false,
})
EOF
```

## Contributing

Any and all contributions are greatly appreciated!

### Issues

If you found a bug or want to request a feature, pleases do so by [raising an issue](https://github.com/b3nj5m1n/kommentary/issues/new/choose).

### Pull Requests

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Run the unit tests if you changed anything affected by them
5. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the Branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

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
