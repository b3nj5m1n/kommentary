# kommentary

Neovim plugin to comment text in and out, written in lua. Supports commenting out the current line, a visual selection and a motion/textobject.

![](https://s2.gifyu.com/images/Peek-2021-01-30-23-12.gif)

## Install

### Packer

```lua
use 'b3nj5m1n/kommentary'
```

### Vim-Plug

```viml
Plug 'b3nj5m1n/kommentary'
```

## Configuration

### Configure unsupported language

Replace rust with the filetype you want to configure, the first field in the table with the prefix for single-line comments (A whitespace character gets added by default after a prefix and before a suffix) or false if the language doesn't support single-line comments, and the second field with a table containing the prefix and suffix for multi-line comments (including whitespace) or false if the language doesn't support multi-line comments.
```lua
require('kommentary.config').config["rust"] = {"// ", {"/* ", " */"}}
```

## Documentation

The code is heavily commented, functions are documented with using [LDoc](https://github.com/lunarmodules/LDoc).

You can build the documentation with this command:
```
ldoc .
```
Then you can access it from doc/index.html
