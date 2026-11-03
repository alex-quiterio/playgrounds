-- Day 17: Two Steps Forward
local here = arg[0]:match("(.*/)") or "./"
package.path = here .. "../lib/?.lua;" .. package.path
local md5 = require("md5")

local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local passcode = file:read("*l"):match("%S+")
file:close()

-- Doors up, down, left, right are open when the matching one of the first
-- four hex digits of md5(passcode .. path) is b-f.
local MOVES = { { "U", 0, -1 }, { "D", 0, 1 }, { "L", -1, 0 }, { "R", 1, 0 } }

-- Breadth-first over every path: the first to reach the vault is the
-- shortest, and the last one found is the longest (part 2).
local shortest, longest = nil, 0
local frontier = { { 0, 0, "" } }
while #frontier > 0 do
  local next_frontier = {}
  for _, state in ipairs(frontier) do
    local x, y, path = state[1], state[2], state[3]
    if x == 3 and y == 3 then
      shortest = shortest or path
      longest = #path
    else
      local h = md5.hex(passcode .. path)
      for i, m in ipairs(MOVES) do
        local nx, ny = x + m[2], y + m[3]
        if nx >= 0 and nx <= 3 and ny >= 0 and ny <= 3 and h:sub(i, i):match("[b-f]") then
          next_frontier[#next_frontier + 1] = { nx, ny, path .. m[1] }
        end
      end
    end
  end
  frontier = next_frontier
end

print(shortest)
print(longest)
