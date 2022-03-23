" define a command to act as a bridge between vim and lua
command! -nargs=* ScratchPad lua require('scratchpad').call(<f-args>)
command! -nargs=* Scratchpad lua require('scratchpad').call(<f-args>)



