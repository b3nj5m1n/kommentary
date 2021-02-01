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

### Configure unsupported language

Replace rust with the filetype you want to configure, the first field in the table with the prefix for single-line comments (A whitespace character gets added by default after a prefix and before a suffix) or false if the language doesn't support single-line comments, and the second field with a table containing the prefix and suffix for multi-line comments (including whitespace) or false if the language doesn't support multi-line comments.
```lua
require('kommentary.config').config["rust"] = {"//", {"/*", "*/"}}
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
