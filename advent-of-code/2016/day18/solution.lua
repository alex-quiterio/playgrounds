-- Day 18: Like a Rogue
-- The input is the first row. The example adds its own row count after it
-- (".^^.^.^^^^ 10"); the real room has 40 rows, then 400000 for part 2.
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local text = file:read("a")
file:close()
local first = text:match("[%.%^]+")
local example_rows = tonumber(text:match("[%.%^]+%s+(%d+)"))

-- A tile is a trap exactly when its left and right neighbours differ.
local function safe_tiles(rows)
  local width, row = #first, {}
  for i = 1, width do row[i] = first:sub(i, i) == "^" end
  local safe = 0
  for _ = 1, rows do
    local nxt = {}
    for i = 1, width do
      if not row[i] then safe = safe + 1 end
      nxt[i] = (row[i - 1] or false) ~= (row[i + 1] or false)
    end
    row = nxt
  end
  return safe
end

if example_rows then
  print(safe_tiles(example_rows))
else
  print(safe_tiles(40))
  print(safe_tiles(400000))
end
