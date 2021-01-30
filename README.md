# kommentary

Plugin to comment text in and out, written in lua.

## To-do

- [x] Single-line comments
- [ ] Multi-line comments
- [ ] Docstrings

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

Replace rust with the filetype you want to configure, the first field in the table with the prefix for single-line comments (including whitespace) or false if the language doesn't support single-line comments, and the second field with a table containing the prefix and suffix for multi-line comments (including whitespace) or false if the language doesn't support multi-line comments.
```lua
require('kommentary.config').config["rust"] = {"// ", {"/* ", " */"}}
```
