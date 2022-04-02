" define a command to act as a bridge between vim and lua
command! -nargs=* ScratchPad lua require('scratchpad').invoke(<f-args>)

" defaults
let g:scratchpad_autosize = get(g:, 'scratchpad_autosize', 1)
let g:scratchpad_autostart = get(g:, 'scratchpad_autostart', 1)

let g:scratchpad_textwidth = get(g:, 'scratchpad_textwidth', 80)
let g:scratchpad_minwidth = get(g:, 'scratchpad_minwidth', 12)

let g:scratchpad_location = get(g:, 'scratchpad_location', '~/.scratchpad')

let g:scratchpad_daily = get(g:, 'scratchpad_daily', 0)
let g:scratchpad_daily_location = get(g:, 'scratchpad_daily', '~/.daily_scratchpad')
let g:scratchpad_daily_format = get(g:, 'scratchpad_daily_format', '%Y-%m-%d')

" setup auto-resize, auto-start commands
autocmd BufEnter,VimResized * if g:scratchpad_autosize | execute 'lua require("scratchpad").auto()' | endif
autocmd VimEnter * if g:scratchpad_autostart | execute ':ScratchPad' | endif

hi ScratchPad ctermfg=239

