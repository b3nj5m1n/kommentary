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
    local map_name = args[2]
    --[[ When called with the calling context of init (This would be for triggered
    by gc for example) return g@ (Which has to be inserted into the mapping literaly,
    meaning the mapping has to be an <expr>) and set the operatorfunc, which is the
    function that will be called after a motion, provided you entered g@ before.
    The process will be as follows: typing gc will set the operator func and return g@,
    since the mapping is an <expr> it's like mapping gc to g@, so g@ will be typed,
    if you now do a motion like 5j, the operatorfunc gets called with a special,
    automatically set argument containing information about the nature of the motion.
    For more information, see :h operatorfunc. ]]
    -- if calling_context == context.init then
        -- vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.go')
        -- return "g@"
    -- end
    if calling_context == context.visual then
        M.create_next_toggle_func(calling_context, util.callbacks[map_name])()
        return
    end

    M.next_toggle_func = M.create_next_toggle_func(calling_context, util.callbacks[map_name])
    vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.next_toggle_func')
    return 'g@' .. (calling_context==context.motion and '' or 'l')        
end

M.next_toggle_func = function() 
    return
end
function M.create_next_toggle_func(calling_context, callback)
     return function()
        local line_number_start, line_number_end, new_calling_context = M.get_lines_from_context(calling_context)
        if callback ~= nil then
            callback(line_number_start, line_number_end, calling_context, {
                config = config,
                kommentary = kommentary,
                modes = modes
            })
        else 
            M.toggle_comment(line_number_start, line_number_end, new_calling_context)
        end
    end
end

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
        calling_context = context.motion
    end
    return line_number_start, line_number_end, calling_context
end

function M.toggle_comment(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    -- local calling_context = args[3]
    kommentary.toggle_comment_range(line_number_start, line_number_end, modes.normal)
end

function M.toggle_comment_singles(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    local mode = modes.force_single
    kommentary.toggle_comment_range(line_number_start, line_number_end, mode)
end

return M
