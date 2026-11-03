-- Day 13: A Maze of Twisty Little Cubicles
-- The input is the office designer's favourite number. The example adds its
-- own target after it ("10 7,4"); the real target is 31,39.
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local text = file:read("a")
file:close()
local favourite = tonumber(text:match("%d+"))
local tx, ty = text:match("%d+%s+(%d+),(%d+)")
tx, ty = tonumber(tx) or 31, tonumber(ty) or 39

local function open(x, y)
  if x < 0 or y < 0 then return false end
  local n, bits = x * x + 3 * x + 2 * x * y + y + y * y + favourite, 0
  while n > 0 do bits, n = bits + (n & 1), n >> 1 end
  return bits % 2 == 0
end

-- Breadth-first search from 1,1, recording each location's distance.
local dist = { ["1,1"] = 0 }
local queue, head = { { 1, 1 } }, 1
local steps_to_target, within_50 = nil, 0
while head <= #queue do
  local x, y = queue[head][1], queue[head][2]
  head = head + 1
  local d = dist[x .. "," .. y]
  if d <= 50 then within_50 = within_50 + 1 end
  if x == tx and y == ty then steps_to_target = d end
  if steps_to_target and d > 50 then break end
  for _, m in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
    local nx, ny = x + m[1], y + m[2]
    local key = nx .. "," .. ny
    if not dist[key] and open(nx, ny) then
      dist[key] = d + 1
      queue[#queue + 1] = { nx, ny }
    end
  end
end

print(steps_to_target)
-- Part 2: how many locations are at most 50 steps away.
print(within_50)
