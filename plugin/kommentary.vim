lua kommentary = require("kommentary")
lua config = require("kommentary.config")
lua config.setup()

" The default mapping for line-wise operation; will toggle the range from
" commented to not-commented and vice-versa, will use a single-line comment.
nmap gcc     <Plug>kommentary_line_default
" The default mapping for visual selections; will toggle the range from
" commented to not-commented and vice-versa, will use multi-line comments when
" the range is longer than 1 line, otherwise it will use a single-line comment.
vmap gc     <Plug>kommentary_visual_default
" The default mapping for motions; will toggle the range from commented to
" not-commented and vice-versa, will use multi-line comments when the range
" is longer than 1 line, otherwise it will use a single-line comment.
nmap gc     <Plug>kommentary_motion_default

nmap <leader>cic     <Plug>kommentary_line_increase
nmap <leader>ci     <Plug>kommentary_motion_increase
vmap <leader>ci     <Plug>kommentary_visual_increase
nmap <leader>cdc     <Plug>kommentary_line_decrease
nmap <leader>cd     <Plug>kommentary_motion_decrease
vmap <leader>cd     <Plug>kommentary_visual_decrease
