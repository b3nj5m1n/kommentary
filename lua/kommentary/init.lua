--[[--
Initialization.

This module handles the initialization of the plugin.
]]
local kommentary = require("kommentary.kommentary")
local config = require("kommentary.config")
local util = require("kommentary.util")
local M = {}
local context = util.enum({"line", "visual", "motion", "init"})
local modes = config.get_modes()

--[[--
Function to be called by mappings.
This acts as a middle-man, when called it will figure out the context of the
call, so if it was called on a single line, or from a selection/motion, and
also the range of the operation, so on which line to start and end.
It will then call another function which takes care of calling the functions
in kommentary.kommentary, which then actually comments out the range.
You can overload this function with another function as an argument, which
will overwrite the function that gets called at the end. The arguments
passed to the second function are: line_number_start, line_number_end, context
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
    -- The 3 possible contexts from which this function can be called
    local calling_context = args[1]
    local line_number_start = nil
    local line_number_end = nil
    local callback_function = args[2]
    --[[ If the second argument is not nil, it's a table containing the callback
    function, extract that function from the table ]]
    if type(callback_function) == "table" then
        callback_function = callback_function[1]
    end
    --[[ When called without any arguments (gc), return g@ (Which will be inserted
    into the mapping literaly, since the mapping is an <expr>, so you have gc
    will enter g@), before that set operatorfunc, which is the function that
    will be called after a motion, when you entered g@ before. So finally,
    typing gc will be as if you typed g@, then you can do a motion like 5j,
    now the operatorfunc gets called and has information about the motion,
    such as the range on which the motion operated. See :h operatorfunc. ]]
    if calling_context == context.init then
        vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.go')
        return "g@"
    end
    --[[ Special argument passed by <Plug>KommentaryLine (gcc) to operate
    on just the current line ]]
    if calling_context == context.line then
        line_number_start = vim.api.nvim_win_get_cursor(0)[1]
	line_number_end = line_number_start
    elseif calling_context == context.visual then
        --[[ When using g@, the marks < and > will contain the position of the
        start and the end of the selection, respectively. vim.fn.getpos() returns
        a tuple with the line and column of the position. ]]
        line_number_start = vim.fn.getpos('v')[2]
        line_number_end = vim.fn.getcurpos()[2]
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
