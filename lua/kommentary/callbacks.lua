local M = {}

function M.increase_comment_level(line_number_start, line_number_end, _)
    local config = require('kommentary.config')
    local kommentary = require('kommentary.kommentary')
    local modes = config.get_modes()
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

function M.decrease_comment_level(line_number_start, line_number_end, _)
    local config = require('kommentary.config')
    local kommentary = require('kommentary.kommentary')
    if line_number_start > line_number_end then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    kommentary.comment_out_range(line_number_start, line_number_end, config.get_config(0))
end

function M.multicomment_single(line_number_start, line_number_end, _)
    local config = require('kommentary.config')
    local kommentary = require('kommentary.kommentary')
    if line_number_start > line_number_end then
        line_number_start, line_number_end = line_number_end, line_number_start
    end
    if kommentary.is_comment(line_number_start, line_number_end, config.get_config(0)) then
      kommentary.comment_out_range(line_number_start, line_number_end, config.get_config(0))
    else
      kommentary.comment_in_range_single(line_number_start, line_number_end, config.get_config(0))
    end
end

return M
