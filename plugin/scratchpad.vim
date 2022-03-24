" define a command to act as a bridge between vim and lua
command! -nargs=* ScratchPad lua require('scratchpad').invoke(<f-args>)

" setup auto-resize, auto-start commands
autocmd BufEnter,VimResized * if g:scratchpad_autosize | execute 'lua require("scratchpad").auto()' | endif
autocmd VimEnter * if g:scratchpad_autostart | execute ':ScratchPad' | endif

" defaults
let g:scratchpad_autosize = 1
let g:scratchpad_autostart = 1

let g:scratchpad_textwidth = 80
let g:scratchpad_minwidth = 12

let g:scratchpad_location = '~/.scratchpad'

hi ScratchPad ctermfg=239

