# ScratchPad

A snazzy neovim plugin to centre your buffer by creating a persistent
scratchpad off to the left.

![scratchpad-vid](https://raw.githubusercontent.com/FraserLee/readme_resources/main/resize.gif)

<br><br>
# Installation

If you're reading this you've probably already got a plugin manager. If not, I
recommend [Vim-Plug](https://github.com/junegunn/vim-plug), but they're essentially
interchangeable. Add the appropriate line in the appropriate spot in your
`.vimrc` file.

```vim
" vim-plug
Plug 'FraserLee/ScratchPad'

" vundle
Plugin 'FraserLee/ScratchPad'

" packer.nvim
use 'FraserLee/ScratchPad'

" etc...
```

Run your version of `:PlugInstall` and things should be good to go.

<br><br><br><br>
# Usage

```vim
nnoremap <leader>cc <cmd>ScratchPad<cr>
```
---

By default, all scratchpad windows point to one underlying file
(`~/.scratchpad` unless changed). They'll auto-save when modified,
reload if the file is changed, and automatically close when all other
windows are gone.

I tend to use them as the digital equivalent of the sticky notes that coat
all objects vaguely proximate to my desk, but that's not a requirement.

- `:ScratchPad` to toggle the scratchpad
- `:ScratchPad open` opens a new scratchpad
- `:ScratchPad close` closes all scratchpads in the current tab

<br><br><br><br>
# Configuration

By default, the scratchpad will auto-open when you open vim, and automatically
open / close / resize itself as the window size (and spilt) changes.


Disable scratchpad on startup:
```vim
let g:scratchpad_autostart = 0
```

Disable automatic resizing:
```vim
let g:scratchpad_autosize = 0
```

### Automatic Size Junk

The assumed width of code, as per what will be centred on screen. Set this to the same
thing as any sort of colour column.

```vim
let g:scratchpad_textwidth = 80 " (80 is the default)
```

The minimum width of a ScratchPad before it will - if autosize is enabled -
close itself.

```vim
let g:scratchpad_minwidth = 12
```

## File Locations

Change the scratchpad file by
```vim
let g:scratchpad_location = '~/.scratchpad'
```

Auto-focus when opening a scratchpad window:
```vim
let g:scratchpad_autofocus = 1
```

### Daily ScratchPad
Instead of having one ScratchPad have a fresh one for each day.
The old ScratchPads are saved as well. Disabled by default.

Enable daily scratchpad
```vim
let g:scratchpad_daily = 1
```

Change the daily scratchpad directory
```vim
let g:scratchpad_daily_location = '~/.daily_scratchpad'
```

Change the daily scratchpad file name format using [lua os date](https://www.lua.org/pil/22.1.html)
```vim
let g:scratchpad_daily_format = '%Y-%m-%d'
```

---

Edit colour with
```vim
hi ScratchPad ctermfg=X ctermbg=Y
```


<br><br><br><br>
# Making Stuff Look (somewhat) Decent

I've added a line to disable the
[virtual-text colour column](https://github.com/lukas-reineke/virt-column.nvim)
in scratchpad buffers if that plugin's found, since I think these two pair
pretty well together. If you want to get something looking similar to the
screenshots, here's a start.

```vim
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'fraserlee/ScratchPad'
Plug 'lukas-reineke/virt-column.nvim'
call plug#end()

" ------------------------------ SETUP ---------------------------------------

se nu             " Turn on line numbers
se colorcolumn=80 " Set the colour-column to 80

noremap <SPACE> <Nop>
let mapleader=" "

" <space>cc to toggle ScratchPad
nnoremap <leader>cc <cmd>ScratchPad<cr>

lua << EOF
    require('virt-column').setup{ char = '|' }
EOF

" -------------------------- COLOUR SCHEME -----------------------------------

colorscheme gruvbox
let g:gruvbox_contrast_dark = 'hard'
se background=dark

" Set the colourcolumn background to the background colour,
" foreground to the same as the window split colour

execute "hi ColorColumn ctermbg=" .
            \matchstr(execute('hi Normal'), 'ctermbg=\zs\S*')
hi! link VirtColumn VertSplit
```

![1](https://raw.githubusercontent.com/FraserLee/readme_resources/main/screenshot%201.png)
![2](https://raw.githubusercontent.com/FraserLee/readme_resources/main/screenshot%202.png)
![3](https://raw.githubusercontent.com/FraserLee/readme_resources/main/screenshot%203.png)
