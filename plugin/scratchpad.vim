" define a command to act as a bridge between vim and lua
command! -nargs=* ScratchPad lua require('scratchpad').invoke(<f-args>)
command! -nargs=* Scratchpad lua require('scratchpad').invoke(<f-args>)

let g:scratchpad_fg = 239 
let g:scratchpad_bg = matchstr(execute('hi Normal'), 'ctermbg=\zs\S*')

