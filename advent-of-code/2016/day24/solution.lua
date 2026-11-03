-- Day 24: Air Duct Spelunking
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local grid, points = {}, {}
for line in file:lines() do
  if line ~= "" then
    grid[#grid + 1] = line
    for x, digit in line:gmatch("()(%d)") do points[tonumber(digit)] = { x, #grid } end
  end
end
file:close()

-- Breadth-first from each numbered spot gives the distance between every pair.
local function distances_from(start)
  local dist = { [start[2] * 1000 + start[1]] = 0 }
  local queue, head, found = { start }, 1, {}
  while head <= #queue do
    local x, y = queue[head][1], queue[head][2]
    head = head + 1
    local d = dist[y * 1000 + x]
    local c = grid[y]:sub(x, x)
    if c:match("%d") then found[tonumber(c)] = d end
    for _, m in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local nx, ny = x + m[1], y + m[2]
      local k = ny * 1000 + nx
      if not dist[k] and grid[ny] and grid[ny]:sub(nx, nx) ~= "#" then
        dist[k] = d + 1
        queue[#queue + 1] = { nx, ny }
      end
    end
  end
  return found
end

local count, dist = 0, {}
for i = 0, 9 do if points[i] then count = i + 1 end end
for i = 0, count - 1 do dist[i] = distances_from(points[i]) end

-- Then try every order of visiting the other spots, starting from 0.
local best, best_return = math.huge, math.huge
local visited = { [0] = true }
local function tour(at, seen, length)
  if seen == count then
    best = math.min(best, length)
    best_return = math.min(best_return, length + dist[at][0])
    return
  end
  for next = 1, count - 1 do
    if not visited[next] then
      visited[next] = true
      tour(next, seen + 1, length + dist[at][next])
      visited[next] = false
    end
  end
end
tour(0, 1, 0)

print(best)
-- Part 2: the robot also has to come back to 0.
print(best_return)
