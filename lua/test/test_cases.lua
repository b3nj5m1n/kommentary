local M = {}

M.comment_in_range_single_content = {
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      | import antigravity
      |
      | def hello():
      |     print('hello')
      |
      |     print('world')
    ]],
    output = [[
      | # import antigravity
      | #
      | # def hello():
      | #     print('hello')
      | #
      | #     print('world')
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
    output = [[
      |     # for i in range(42):
      |     #     x = i * i
      |     #
      |     #     # print(x)
    ]],
  },
}

M.comment_out_range_single_content = {
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      | # import antigravity
      | #
      | # def hello():
      | #     print('hello')
      | #
      | #     print('world')
    ]],
    output = [[
      | import antigravity
      |
      | def hello():
      |     print('hello')
      |
      |     print('world')
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      | #     for i in range(42):
      | #         x = i * i
      | #
      | #         # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     # for i in range(42):
      |     #     x = i * i
      |     #
      |     #     # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     # for i in range(42):
      |     #     x = i * i
      |
      |     #     # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     #for i in range(42):
      |     #    x = i * i
      |     #
      |     #    # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     # for i in range(42):
      |           # x = i * i
      |
      |           # # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     # for i in range(42):
      |           # x = i * i
      |           #
      |           # # print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
  {
    config = { "#", nil, nil, nil, true, false },
    input = [[
      |     #for i in range(42):
      |         #x = i * i
      |
      |         ## print(x)
    ]],
    output = [[
      |     for i in range(42):
      |         x = i * i
      |
      |         # print(x)
    ]],
  },
}

M.comment_in_range_content = {

}

M.comment_out_range_content = {

}

return M
