local scratchpad = {}

local api = vim.api
local fn  = vim.fn

-- TODO: make toggle actually toggle
-- TODO: auto-start on startup
-- TODO: more transparent scratchpad text
-- TODO: resize on window resize, auto enable and disable when multiple windows, too thin, etc
-- TODO: virtual-text colourcolumn when active

function scratchpad.toggle()
    local main_win_id   = fn.win_getid()
    local main_win_info = fn.getwininfo(main_win_id)[1]

    local width = main_win_info.width - main_win_info.textoff
    local excess = width - 80 -- TODO: use a config variable
    local excess_left = math.floor(excess / 2)

    --- create a buffer to the left of the current one, resize, and set a few options
    api.nvim_command('vsplit')
    api.nvim_win_set_width(0, excess_left)
    api.nvim_command('edit ~/.scratchpad') -- TODO: configurable by variable
    api.nvim_command('setlocal autowrite')
    api.nvim_command('setlocal autowriteall')
    api.nvim_command('setlocal autoread')
    api.nvim_command('autocmd InsertLeave,TextChanged <buffer> :w')
    api.nvim_command('autocmd BufEnter <buffer> lua require"scratchpad".check_if_should_close()')
    api.nvim_buf_set_var(0, 'is_scratchpad', true)

    --- set the cursor back to the main window
    api.nvim_set_current_win(main_win_id)
end

-- return number of scratchpads on current tab
function scratchpad.count()
    local tab_id = api.nvim_get_current_tabpage()
    local windows = api.nvim_tabpage_list_wins(tab_id)

    local scratchpad_count = 0
    for _, win_id in ipairs(windows) do
        local buffer_id = api.nvim_win_get_buf(win_id)

        local is_scratchpad = fn.getbufvar(buffer_id, 'is_scratchpad')
        if type(is_scratchpad) == 'boolean' and is_scratchpad then
            scratchpad_count = scratchpad_count + 1
        end
    end

    return scratchpad_count, #windows
end

-- if all windows on the current tab are scratchpad windows, close the tab
function scratchpad.check_if_should_close()

    local scratchpad_count, total_count = scratchpad.count()

    if scratchpad_count == total_count then
        -- api.nvim_win_close(0, false)
        api.nvim_command(':q') -- bit janky, but it does the job
    end
end

function scratchpad.call(...)
    local args = {...}
    if #args == 0 then
        scratchpad.toggle()
    end
end

return scratchpad
