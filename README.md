# scratchpad (wip)

Currently in the works. Come back later.

```
nnoremap <leader>cc <cmd>ScratchPad<cr>
```

---

- toggle: `:ScratchPad`
- open: `:ScratchPad open`
- close: `:ScratchPad close`

Edit colour with

```
hi ScratchPad ctermfg=X ctermbg=Y
```

### Text Properties

The assumed width of code, what will be centred on screen. Set this to the same thing as any sort of colour column.
```
let g:scratchpad_textwidth = 80
```

The minimum width of a ScratchPad before it will try to close itself.
```
let g:scratchpad_minwidth = 12
```

The path of the scratchpad
```
let g:scratchpad_location = '~/.scratchpad'
```

---

Disable automatic resizing:
```
let g:scratchpad_autosize = 0
```

Disable scratchpad on startup:
```
let g:scratchpad_autostart = 0
```
