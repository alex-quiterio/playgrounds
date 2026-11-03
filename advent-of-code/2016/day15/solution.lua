-- Day 15: Timing is Everything
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local discs = {}
for line in file:lines() do
  local n, start = line:match("has (%d+) positions; at time=0, it is at position (%d+)")
  if n then discs[#discs + 1] = { size = tonumber(n), start = tonumber(start) } end
end
file:close()

-- The capsule reaches disc k at time t + k, and passes when that disc is
-- at position 0. Sieve one disc at a time: once a time works for the
-- first discs, stepping by the product of their sizes keeps them aligned.
local function first_time()
  local t, step = 0, 1
  for k, disc in ipairs(discs) do
    while (disc.start + t + k) % disc.size ~= 0 do t = t + step end
    step = step * disc.size
  end
  return t
end

print(first_time())
-- Part 2: a new disc with 11 positions, at position 0, below the others.
discs[#discs + 1] = { size = 11, start = 0 }
print(first_time())
