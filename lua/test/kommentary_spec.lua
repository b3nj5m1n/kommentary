local kommentary = require("kommentary.kommentary")
local test_cases = require("test.test_cases")

local function parse_friendly_string(s)
  local lines = string.gmatch(s, "[^\r\n]+")
  local matches = {}

  for line in lines do
    local match = string.match(line, "\n?%s*| ?([^\n]*)")
    table.insert(matches, match)
  end

  return matches
end

local function run_test_cases(
  cases, forward, backward, forward_name, backward_name
)
  for i, case in ipairs(cases) do
    local input = parse_friendly_string(case.input)
    local expected = parse_friendly_string(case.output)
    local actual = forward(input, case.config)

    if case.enabled ~= nil and case.enabled == false then
      return
    end

    local test_name = string.format("%s (#%d)", forward_name, i)
    it(test_name, function ()
      assert.are.same(expected, actual)
    end)

    if backward ~= nil then
      local reconstructed = backward(actual, case.config)
      local test_name = string.format("%s (#%d)", backward_name, i)
      it(test_name, function ()
        assert.are.same(input, reconstructed)
      end)
    end
  end
end

describe("comment", function ()

  run_test_cases(
    test_cases.comment_in_range_single_content,
    kommentary.comment_in_range_single_content,
    kommentary.comment_out_range_single_content,
    "in range single",
    "in then out range single"
  )

  run_test_cases(
    test_cases.comment_out_range_single_content,
    kommentary.comment_out_range_single_content,
    nil,
    "out range single",
    nil
  )

  run_test_cases(
    test_cases.comment_in_range_content,
    kommentary.comment_in_range_content,
    kommentary.comment_out_range_content,
    "in range",
    "in then out range"
  )

  run_test_cases(
    test_cases.comment_out_range_content,
    kommentary.comment_out_range_content,
    nil,
    "out range",
    nil
  )

end)
