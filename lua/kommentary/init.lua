--[[--
Initialization.

This module handles the initialization of the plugin.
]]
local kommentary = require("kommentary.kommentary")
local config = require("kommentary.config")
local M = {}
local context = config.context
local modes = config.get_modes()

--[[--
Function to be called by mappings.
This function should be called by all the mappings, it will figure out two things:
    * The context of the call, meaning if the mapping was triggered in on a
      single line, or from a selection/motion
    * The range of the operation, meaning on which line the operation starts and ends.
This function does not, however, manipulate the buffer in any way, that is left up to
other functions to allow for greater customizability. At the end of this function, it
will call a *callback* function with the following arguments:
    line_number_start, line_number_end, context
This callback function, by default, will be `kommentary.toggle_comment`, and will
toggle the range specified. If you wish to use a different function, you can provide
it in a table as the third argument to this function `kommentary.go`, for example, if
the desired callback function were called `kommentary.toggle_comment_singles`,
then you would call this function like this:
    `kommentary.go(context, {kommentary.toggle_comment_singles})`
@tparam string ... Optional string indicating the mode to choose, 'single_line'
	will operate on the current line, 'visual' will use the current visual
	selection, otherwise it will assume a motion (Arguments will be
	automatically passed by operatorfunc).
@tparam ?string|function ... Optional function to call instead of the normal
toggle_comment at the end of this function
@treturn ?string|nil If called without arguments, it sets itself as operatorfunc
	and returns 'g@' to be used in an expression mapping, otherwise it will
	comment out and not return anything.
]]
function M.go(...)
    local args = {...}
    --[[ The first argument passed to this function represents one of 3 possible
    contexts in which this function can be called. ]]
    local calling_context = args[1]
    local line_number_start = nil
    local line_number_end = nil
    local callback_function = args[2]
    --[[ If the second argument is not nil, it's a table containing the callback
    function, extract that function from the table, otherwise leave it as nil ]]
    if type(callback_function) == "table" then
        callback_function = callback_function[1]
    end
    --[[ When called with the calling context of init (This would be for triggered
    by gc for example) return g@ (Which has to be inserted into the mapping literaly,
    meaning the mapping has to be an <expr>) and set the operatorfunc, which is the
    function that will be called after a motion, provided you entered g@ before.
    The process will be as follows: typing gc will set the operator func and return g@,
    since the mapping is an <expr> it's like mapping gc to g@, so g@ will be typed,
    if you now do a motion like 5j, the operatorfunc gets called with a special,
    automatically set argument containing information about the nature of the motion.
    For more information, see :h operatorfunc. ]]
    if calling_context == context.init then
        vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.go')
        return "g@"
    end
    if calling_context == context.line then
        line_number_start = vim.api.nvim_win_get_cursor(0)[1]
	line_number_end = line_number_start
    elseif calling_context == context.visual then
        --[[ vim.fn.getpos will return the position of something,
        if you pass 'v' as an argument you will get the start of a
        visual selection, vim.fn.getcurspos will return the current
        position of the cursor, so the end of the visual selection. ]]
        line_number_start = vim.fn.getpos('v')[2]
        line_number_end = vim.fn.getcurpos()[2]
    --[[ When executing a motion after g@, operatorfunc will be
    called with one of these 3 strings as an argument indicating
    on what the motion operates, we use it to detect if this function
    is being called after a motion ]]
    elseif args[1] == "line" or
	    args[1] == "char" or
	    args[1] == "block" then
        --[[ When using g@, the marks [ and ] will contain the position of the
        start and the end of the motion, respectively. vim.fn.getpos() returns
        a tuple with the line and column of the position. ]]
        line_number_start = vim.fn.getpos("'[")[2]
        line_number_end = vim.fn.getpos("']")[2]
        calling_context = context.motion
    end
    if callback_function == nil then
	    M.toggle_comment(line_number_start, line_number_end, calling_context)
    else
	    callback_function(line_number_start, line_number_end, calling_context)
    end
end

function M.toggle_comment(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    local calling_context = args[3]
    local mode = modes.normal
    if calling_context == context.line then
	    mode = modes.force_single
    end
    kommentary.toggle_comment_range(line_number_start, line_number_end, mode)
end

function M.toggle_comment_singles(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    local mode = modes.force_single
    kommentary.toggle_comment_range(line_number_start, line_number_end, mode)
end

return M
