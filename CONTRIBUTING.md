# Contributing

## Adding a language

Please do not create new any  new local variables, either set the full config immediately or use the default config.

So not like this:
```lua
local hashtag = {"#", false}
local config = {
    ["c"] = default,
    ["cpp"] = default,
    ["cs"] = default,
    ["go"] = default,
    ["java"] = default,
    ["javascript"] = default,
    ["kotlin"] = default,
    ["lua"] = {"--", {"--[[", "]]"}},
    ["markdown"] = {false, {"<!---", "-->"}},
    ["rust"] = default,
    ["swift"] = default,
    ["vim"] = {"\"", false},
   +["ruby"] = hashtag,
   +["r"] = hashtag,
   +["python"] = hashtag,
}
```

But like this:
```lua
local config = {
    ["c"] = default,
    ["cpp"] = default,
    ["cs"] = default,
    ["go"] = default,
    ["java"] = default,
    ["javascript"] = default,
    ["kotlin"] = default,
    ["lua"] = {"--", {"--[[", "]]"}},
    ["markdown"] = {false, {"<!---", "-->"}},
    ["rust"] = default,
    ["swift"] = default,
    ["vim"] = {"\"", false},
   +["ruby"] = {"#", false},
   +["r"] = {"#", false},
   +["python"] = {"#", false},
}
```

Also, please sort the table after making your changes, so instead of the above, please submit this:
```lua
local config = {
    ["c"] = default,
    ["cpp"] = default,
    ["cs"] = default,
    ["go"] = default,
    ["java"] = default,
    ["javascript"] = default,
    ["kotlin"] = default,
    ["lua"] = {"--", {"--[[", "]]"}},
    ["markdown"] = {false, {"<!---", "-->"}},
   +["python"] = {"#", false},
   +["r"] = {"#", false},
   +["ruby"] = {"#", false},
    ["rust"] = default,
    ["swift"] = default,
    ["vim"] = {"\"", false},
}
```
In Vim, you can visually select the content of the table, then type `:'<,'>sort` to sort the range.
