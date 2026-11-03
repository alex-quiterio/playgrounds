-- Day 1: No Time for a Taxicab
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local text = file:read("*a")
file:close()

-- Headings in clockwise order: north, east, south, west.
local dx = { 0, 1, 0, -1 }
local dy = { 1, 0, -1, 0 }

local x, y, heading = 0, 0, 1
local visited = { ["0,0"] = true }
local first_repeat

for turn, blocks in text:gmatch("([LR])(%d+)") do
  heading = (heading + (turn == "R" and 0 or 2)) % 4 + 1
  -- Walk one block at a time so part 2 sees every location passed through.
  for _ = 1, tonumber(blocks) do
    x, y = x + dx[heading], y + dy[heading]
    local key = x .. "," .. y
    if visited[key] and not first_repeat then
      first_repeat = math.abs(x) + math.abs(y)
    end
    visited[key] = true
  end
end

print(math.abs(x) + math.abs(y))
if first_repeat then print(first_repeat) end
