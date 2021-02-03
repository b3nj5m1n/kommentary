--[[--
Initialization.

This module handles the initialization of the plugin.
]]
local kommentary = require("kommentary.kommentary")
local config = require("kommentary.config")
local M = {}
local context = config.context
local modes = config.get_modes()

--[[ Since no custom arguments can be passed to operatorfunc, we need to store a
potential custom callback function on initialization ]]
--[[--
Sets the global callback function.
@tparam string callback_function the name of the function to be called by go()
        Only put the function name, no () or args
]]
function M.set_callback_function(callback_function)
    vim.api.nvim_set_var("kommentary_callback_function", callback_function)
end
--[[--
Retrieves the global callback function.
@treturn string returns the name of the global callback function
]]
function M.get_callback_function()
    return vim.api.nvim_get_var("kommentary_callback_function")
end

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
    --[[ If the second argument is not nil, it's a string representing the name
    of the new callback function ]]
    if type(args[2]) == "string" then
        M.set_callback_function(args[2])
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
    if M.get_callback_function() == nil then
        M.toggle_comment(line_number_start, line_number_end, calling_context)
    else
        --[[ Looks pretty bad, doesn't it. So when you set operatorfunc, you have to
        put the name of the function, without any () since when you press g@,
        vim will automatically pass an argument to the operatorfunc. This means
        that we can't specify any arguments for the go function when we're calling
        from a motion. Because of that, we store the function in a global variable,
        but we can't simply use the function there, because that can't be properly
        converted to viml internally, meaning we store the function name instead.
        But now we have to call that function, and the way we do that is using
        lua's load function, which is essentially an eval(), meaning it executes
        lua code from a string. Only that it doesn't execute the code, but it turns
        it into a callable function, and if you execute the return of load() as
        a function, what was in the string gets executed, provided that it was a
        proper function call. So, here we string together said function call.
        Now writing this, I probably missed something really obvious, didn't I? ]]
        local callback_function = load(M.get_callback_function()
            ..  '(' .. line_number_start .. ', ' .. line_number_end
            .. ', ' .. calling_context .. ')')
        callback_function()
    end
    -- We need to make sure we unset the callaback function now.
    M.set_callback_function(nil)
end

function M.toggle_comment(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    -- local calling_context = args[3]
    kommentary.toggle_comment_range(line_number_start, line_number_end, modes.normal)
end

function M.increase_comment_level(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    if line_number_start > line_number_end then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    local mode = config.get_mode(line_number_start, line_number_end, modes.normal)
    if mode == modes.force_single then
        kommentary.comment_in_range_single(line_number_start, line_number_end, config.get_config(0))
    else
        kommentary.comment_in_range(line_number_start, line_number_end, config.get_config(0))
    end
end

function M.decrease_comment_level(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    if line_number_start > line_number_end then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    kommentary.comment_out_range(line_number_start, line_number_end, config.get_config(0))
end

function M.toggle_comment_singles(...)
    local args = {...}
    local line_number_start, line_number_end = args[1], args[2]
    local mode = modes.force_single
    kommentary.toggle_comment_range(line_number_start, line_number_end, mode)
end

return M
