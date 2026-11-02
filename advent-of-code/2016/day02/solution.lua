-- Day 2: Bathroom Security
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local instructions = {}
for line in file:lines() do
  if line:match("%S") then instructions[#instructions + 1] = line end
end
file:close()

local moves = { U = { 0, -1 }, D = { 0, 1 }, L = { -1, 0 }, R = { 1, 0 } }

-- A keypad drawn as rows of text; spaces are where there is no button.
-- Starting on "5", a move that would leave the keypad is ignored.
local function code(layout)
  local keypad = {}
  local x, y
  for row, line in ipairs(layout) do
    keypad[row] = {}
    for col = 1, #line do
      local key = line:sub(col, col)
      if key ~= " " then keypad[row][col] = key end
      if key == "5" then x, y = col, row end
    end
  end
  local result = {}
  for _, line in ipairs(instructions) do
    for step in line:gmatch("[UDLR]") do
      local nx, ny = x + moves[step][1], y + moves[step][2]
      if keypad[ny] and keypad[ny][nx] then x, y = nx, ny end
    end
    result[#result + 1] = keypad[y][x]
  end
  return table.concat(result)
end

print(code({ "123", "456", "789" }))
print(code({ "  1  ", " 234 ", "56789", " ABC ", "  D  " }))
