lua kommentary = require("kommentary")

lua vim.api.nvim_set_keymap('n', '<Plug>Kommentary', 'v:lua.kommentary.toggle_comment()', { noremap = true, expr = true })
lua vim.api.nvim_set_keymap('n', '<Plug>KommentaryLine', '<cmd>call v:lua.kommentary.toggle_comment("single_line")<cr>', { noremap = true, silent = true })
lua vim.api.nvim_set_keymap('v', '<Plug>KommentaryVisual', '<cmd>call v:lua.kommentary.toggle_comment("visual")<cr>', { noremap = true, silent = true })

nmap gc     <Plug>Kommentary
vmap gc     <Plug>KommentaryVisual
" vmap gc     <Plug>KommentaryVisual<C-c>
nmap gcc     <Plug>KommentaryLine
