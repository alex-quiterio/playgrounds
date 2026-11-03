-- Day 22: Grid Computing
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local nodes, width, height = {}, 0, 0
for line in file:lines() do
  local x, y, size, used, avail = line:match("node%-x(%d+)%-y(%d+)%s+(%d+)T%s+(%d+)T%s+(%d+)T")
  if x then
    x, y = tonumber(x), tonumber(y)
    nodes[#nodes + 1] = { x = x, y = y, size = tonumber(size), used = tonumber(used), avail = tonumber(avail) }
    width, height = math.max(width, x + 1), math.max(height, y + 1)
  end
end
file:close()

-- Part 1: pairs (A, B) where A is not empty and its data fits in B.
local viable = 0
for _, a in ipairs(nodes) do
  if a.used > 0 then
    for _, b in ipairs(nodes) do
      if a ~= b and a.used <= b.avail then viable = viable + 1 end
    end
  end
end
print(viable)

-- Part 2: the only move that ever happens is sliding data into the one
-- empty node, like a sliding-tile puzzle. Nodes holding more than the empty
-- node can store never move: they are walls. Search over (empty node, goal
-- data) positions until the goal data reaches 0,0.
local empty, wall = nil, {}
for _, n in ipairs(nodes) do
  if n.used == 0 then empty = n end
end
for _, n in ipairs(nodes) do
  wall[n.y * width + n.x] = n.used > empty.size
end

local function id(ex, ey, gx, gy) return ((ey * width + ex) * height + gy) * width + gx end
local start = { empty.x, empty.y, width - 1, 0 }
local seen = { [id(table.unpack(start))] = true }
local frontier, steps = { start }, 0
local answer
while #frontier > 0 and not answer do
  local next_frontier = {}
  for _, s in ipairs(frontier) do
    local ex, ey, gx, gy = s[1], s[2], s[3], s[4]
    if gx == 0 and gy == 0 then answer = steps; break end
    for _, m in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local nx, ny = ex + m[1], ey + m[2]
      if nx >= 0 and nx < width and ny >= 0 and ny < height and not wall[ny * width + nx] then
        -- The data at (nx, ny) slides into the empty node.
        local ngx, ngy = gx, gy
        if nx == gx and ny == gy then ngx, ngy = ex, ey end
        local k = id(nx, ny, ngx, ngy)
        if not seen[k] then
          seen[k] = true
          next_frontier[#next_frontier + 1] = { nx, ny, ngx, ngy }
        end
      end
    end
  end
  frontier, steps = next_frontier, steps + 1
end
print(answer)
