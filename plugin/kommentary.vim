lua kommentary = require("kommentary")
lua config = require("kommentary.config")

lua config.setup()
nmap gc     <Plug>Kommentary
vmap gc     <Plug>KommentaryVisual
" vmap gc     <Plug>KommentaryVisual<C-c>
nmap gcc     <Plug>KommentaryLine
