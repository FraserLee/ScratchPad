" define a command to act as a bridge between vim and lua
command! -nargs=* ScratchPad lua require('scratchpad').invoke(<f-args>)
" setup auto-resize command
autocmd VimEnter,VimResized,WinEnter * if g:auto_pad | execute 'lua require("scratchpad").auto()' | endif

" defaults
hi ScratchPad ctermfg=239
let g:auto_pad = 1

