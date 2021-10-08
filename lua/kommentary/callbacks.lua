local M = {}

function M.increase_comment_level(line_number_start, line_number_end, calling_context, deps)
    local config = deps.config
    local kommentary = deps.kommentary
    local modes = deps.modes
    if config == nil or kommentary == nil or modes == nil then
        error('Argument "deps" incomplete')
    end
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

function M.decrease_comment_level(line_number_start, line_number_end, calling_context, deps)
    local config = deps.config
    local kommentary = deps.kommentary
    if config == nil or kommentary == nil then
        error('Argument "deps" incomplete')
    end
    if line_number_start > line_number_end then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    kommentary.comment_out_range(line_number_start, line_number_end, config.get_config(0))
end

return M
