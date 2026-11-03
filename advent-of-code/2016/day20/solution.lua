-- Day 20: Firewall Rules
-- Addresses run from 0 to 4294967295. The example sets a smaller range
-- with an extra line, "max 9".
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local ranges, max = {}, 4294967295
for line in file:lines() do
  local lo, hi = line:match("^(%d+)-(%d+)$")
  if lo then ranges[#ranges + 1] = { tonumber(lo), tonumber(hi) } end
  local m = line:match("^max (%d+)$")
  if m then max = tonumber(m) end
end
file:close()

-- Walk the blocked ranges in order of their start, tracking the first
-- address not blocked yet; every gap before the next range is allowed.
table.sort(ranges, function(a, b) return a[1] < b[1] end)
local next_free, lowest, allowed = 0, nil, 0
for _, r in ipairs(ranges) do
  if r[1] > next_free then
    lowest = lowest or next_free
    allowed = allowed + r[1] - next_free
  end
  next_free = math.max(next_free, r[2] + 1)
end
if next_free <= max then
  lowest = lowest or next_free
  allowed = allowed + max - next_free + 1
end

print(lowest)
print(allowed)
