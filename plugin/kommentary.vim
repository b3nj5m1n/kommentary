lua kommentary = require("kommentary")
nnoremap gcc :lua kommentary.toggle_comment()<CR>
nnoremap <leader><leader> :lua kommentary.test()<CR>
