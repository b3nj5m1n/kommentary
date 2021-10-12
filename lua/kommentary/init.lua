--[[--
Initialization.

This module handles the initialization of the plugin.
]]
local kommentary = require("kommentary.kommentary")
local config = require("kommentary.config")
local util = require("kommentary.util")
local M = {}
local context = config.context
local modes = config.get_modes()

--[[--
Function to be called by mappings.
This function should be called by all the mappings. It will receive the context of the
call, meaning if the mapping was triggered in on a single line, or from a selection/motion,
and performs the appropriate setup to comment lines.
This function does not, however, manipulate the buffer in any way, that is left up to
other functions to allow for greater customizability. At the end of this function, it
will do one of two things -
    * call a *callback* function with the following arguments:
          line_number_start, line_number_end, context
      This callback function, by default, will be `kommentary.toggle_comment`, and will
      toggle the range specified. If you wish to use a different function, you can provide
      it in a table as the third argument to this function `kommentary.go`, for example, if
      the desired callback function were called `kommentary.toggle_comment_singles`,
      then you would call this function like this:
          `kommentary.go(context, {kommentary.toggle_comment_singles})`
    * set the operatorfunc to the appropriate callback, and return the
      keys to be used in an <expr> mapping
@tparam int ... The calling context, one of `kommentary.config.context`
@tparam string ... The name of the mapping that is calling this function
@treturn ?string|nil If called from linewise or motion modes, sets the operatorfunc
    and returns 'g@' to be used in an expression mapping, otherwise it will
    comment out and not return anything.
]]
function M.go(...)
    local args = {...}
    --[[ The first argument passed to this function represents one of 3 possible
    contexts in which this function can be called - linewise, motion or visual. The
    second argument is the name of the mapping, which is used to retrieve any custom
    callbacks that are defined for that mapping]]
    local calling_context = args[1]
    local map_name = args[2]
    --[[ When called from visual mode, a new toggle function is created and
    immediately executed, since we do not support dot-repeat for visual mode.
    For other modes (linewise, motion), the toggle function is created and
    stored in a variable, and the operatorfunc is set to that variable (see
    ':h operatorfunc'). If the function is called with a motion, 'g@' is
    returned, which calls the current operatorfunc with the subsequent
    motion. Else (linewise commenting), we return 'g@l', which just calls
    operatorfunc with a dummy motion 'l', which is ignored in the handler
    for linewise commenting. By returning 'g@', the '.' operator can now
    repeat linewise and motion commenting by calling operatorfunc again]]
    if calling_context == context.visual then
        M.create_next_toggle_func(calling_context, util.callbacks[map_name])()
        return
    end

    M.next_toggle_func = M.create_next_toggle_func(calling_context, util.callbacks[map_name])
    vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.next_toggle_func')
    print('Starting mapping')
    return 'g@' .. (calling_context==context.motion and '' or 'l')
end

-- The function to be used to toggle comments. Initially set to a dummy function
M.next_toggle_func = function()
    return
end

--[[ Returns a new toggle function based on the calling context(linewise, visual or motion).
If a callback function is provided, the callback function is used, else the toggle_comment
function is used]]
function M.create_next_toggle_func(calling_context, callback)
     return function()
        local line_number_start, line_number_end = M.get_lines_from_context(calling_context)
        if callback ~= nil then
            callback(line_number_start, line_number_end, calling_context)
        else
            M.toggle_comment(line_number_start, line_number_end, calling_context)
        end
    end
end

-- Returns the starting and ending lines to be commented based on the calling context.
function M.get_lines_from_context(calling_context)
    local line_number_start = nil
    local line_number_end = nil
    if calling_context == context.line then
        line_number_start = vim.fn.line('.')
        line_number_end = line_number_start
    elseif calling_context == context.visual then
        line_number_start = vim.fn.line('v')
        line_number_end = vim.fn.line('.')
    elseif calling_context == context.motion then
        line_number_start = vim.fn.getpos("'[")[2]
        line_number_end = vim.fn.getpos("']")[2]
    end
    return line_number_start, line_number_end
end

function M.toggle_comment(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    kommentary.toggle_comment_range(line_number_start, line_number_end, modes.normal)
end

function M.toggle_comment_singles(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    local mode = modes.force_single
    kommentary.toggle_comment_range(line_number_start, line_number_end, mode)
end

return M
