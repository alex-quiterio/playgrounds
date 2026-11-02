-- Day 3: Squares With Three Sides
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local rows = {}
for line in file:lines() do
  local a, b, c = line:match("(%d+)%s+(%d+)%s+(%d+)")
  if a then rows[#rows + 1] = { tonumber(a), tonumber(b), tonumber(c) } end
end
file:close()

-- A triangle is possible when the two shorter sides add up to more than the
-- longest one, which is the same as their sum beating twice the longest.
local function possible(a, b, c)
  return a + b + c > 2 * math.max(a, b, c)
end

local by_rows = 0
for _, r in ipairs(rows) do
  if possible(r[1], r[2], r[3]) then by_rows = by_rows + 1 end
end

-- Part 2: triangles run down the columns, three rows at a time.
local by_columns = 0
for i = 1, #rows - 2, 3 do
  for col = 1, 3 do
    if possible(rows[i][col], rows[i + 1][col], rows[i + 2][col]) then by_columns = by_columns + 1 end
  end
end

print(by_rows)
print(by_columns)
