local M = { enabled = false }

local api = vim.api
local fn  = vim.fn


-- general module entry-point
function M.invoke(...)
    local args = {...}

    if #args == 0 or string.lower(args[1]) == 'toggle' then
        M.toggle()
    elseif string.lower(args[1]) == 'open' then
        M.open()
    elseif string.lower(args[1]) == 'close' then
        M.close()
    elseif string.lower(args[1]) == 'auto' then
        M.auto()
    else
        print("Invalid argument. Usage:\n \n    :ScratchPad [toggle|open|close|auto]\n")
    end
end


 ------------------------- Internal Functions --------------------------------

-- check if a window is a scratchpad, win_id = 0 -> current window
local function is_scratchpad(win_id)
    local win_var = fn.getwinvar(win_id, 'is_scratchpad')
    return type(win_var) == 'boolean' and win_var
end


-- returns a list of all windows open on the current tab
local function windows()
    local tab_id  = api.nvim_get_current_tabpage()
    return api.nvim_tabpage_list_wins(tab_id)
end


-- returns list of (scratchpads, non-scratchpads) on current tab
local function partition()

    local scratchpads = {}
    local non_scratchpads = {}

    for _, win_id in ipairs(windows()) do
        if is_scratchpad(win_id) then
            table.insert(scratchpads, win_id)
        else
            table.insert(non_scratchpads, win_id)
        end
    end

    return scratchpads, non_scratchpads
end

-- returns number of (scratchpads, non-scratchpads) on current tab
local function count()
    local c = 0
    local window_list = windows()
    for _, win_id in ipairs(window_list) do
        if is_scratchpad(win_id) then c = c + 1 end
    end

    return c, #window_list - c
end


-- given a scratchpad and a non-scratchpad, set sizes so the non-scratchpad is
-- centred with reference to the box of the two. If keep_open is false, the
-- scratchpad might be closed if things are too tight.
local function set_size(non_scratchpad, scratchpad, keep_open)
    local win_info = fn.getwininfo(non_scratchpad)[1]
    local total_width = win_info.width + fn.getwininfo(scratchpad)[1].width
    local total_text = total_width - win_info.textoff

    -- if the scratchpad is too thin, possibly close it
    if total_text < vim.g.scratchpad_textwidth + 2 * vim.g.scratchpad_minwidth and not keep_open then
        M.close()
        return
    end

    local excess = total_text - vim.g.scratchpad_textwidth
    local excess_left = math.max(math.floor(excess / 2), vim.g.scratchpad_minwidth)

    api.nvim_win_set_width(scratchpad, excess_left)
    api.nvim_win_set_width(non_scratchpad, total_width - excess_left)
end


 ---------------------------- Public Functions -------------------------------

-- toggle the scratchpad
function M.toggle()
    local pad_count, _ = count()

    if pad_count == 0 then
        M.enabled = true
        M.open()
    else
        M.enabled = false
        M.close()
    end
end


-- open a scratchpad window
function M.open()
    local main_win_id = fn.win_getid()
    local en_cache = M.enabled
    M.enabled = false

    -- cache splitright setting and reset it to open scratchpad on the left
    local split_cache = api.nvim_get_option('splitright')
    api.nvim_command('set nosplitright')

    -- open a buffer to the left of the current one
    if vim.g.scratchpad_daily == 1 then
        api.nvim_command('vsplit ' .. vim.g.scratchpad_daily_location .. '/' .. os.date(vim.g.scratchpad_daily_format))
    else
        api.nvim_command('vsplit ' .. vim.g.scratchpad_location)
    end
    api.nvim_win_set_var(0, 'is_scratchpad', true)

    if split_cache then api.nvim_command('set splitright') end

    -- set the window sizes
    set_size(main_win_id, fn.win_getid(), true)

    -- setup the autocommand that will close the scratchpad
    api.nvim_command('autocmd BufEnter <buffer> lua require"scratchpad".check_if_should_close()')

    -- setup automatic writing
    api.nvim_command('setlocal autowrite')
    api.nvim_command('setlocal autowriteall')
    api.nvim_command('setlocal autoread')
    api.nvim_command('autocmd InsertLeave,TextChanged <buffer> :w')
    api.nvim_command('setlocal noswapfile')

    -- set the filetype, syntax
    api.nvim_command('setlocal filetype=scratchpad')
    api.nvim_command('syntax match ScratchPad /.*/')

    -- disable virtual-text colour-column in scratchpad if lukas-reineke/virt-column.nvim is loaded
    local hasVC, VC = pcall(require,'virt-column')
    if hasVC then
        VC.buffer_config[vim.api.nvim_get_current_buf()] = {char = ' ', virtcolumn = '' }
    end

    -- set the cursor back to the main window
    api.nvim_set_current_win(main_win_id)
    M.enabled = en_cache
end


-- close all scratchpads on current tab
function M.close()
    for _, win_id in ipairs(windows()) do
        if is_scratchpad(win_id) then
            api.nvim_win_close(win_id, false)
        end
    end
end


-- autocommand, runs on entering a scratchpad buffer:
-- close this scratchpad if all the windows are scratchpads
function M.check_if_should_close()
    local _, non_scratchpads = count()

    if non_scratchpads == 0 then
        api.nvim_command(':q') -- necessary to close the potentially last buffer
    end
end


-- autocommand, if enabled this runs on whenever it might be necessary to resize the scratchpads
function M.auto()
    -- if we're disabled, or currently in a scratchpad, do nothing
    if not M.enabled or is_scratchpad(0) then return end

    local s_count, non_s_count = count()

    if non_s_count ~= 1 then -- more than one window -> disable scratchpads (possibly tweak this?)
        if s_count > 0 then M.close() end
        return
    end


    if s_count > 1 then -- more than one scratchpad -> close and re-open

        M.close()
        M.open()

    elseif s_count == 1 then -- one scratchpad -> resize it

        local scratchpads, non_scratchpads = partition()
        set_size(non_scratchpads[1], scratchpads[1], false)

    else -- no scratchpads -> open one if there's enough space

        local win_info = fn.getwininfo(api.nvim_get_current_win())[1]
        local win_text_width = win_info.width - win_info.textoff
        if win_text_width > vim.g.scratchpad_textwidth + 2 * vim.g.scratchpad_minwidth then
            M.open()
        end
    end
end

return M
