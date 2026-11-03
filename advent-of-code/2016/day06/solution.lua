-- Day 6: Signals and Noise
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local columns = {}
for line in file:lines() do
  for i = 1, #line do
    local counts = columns[i] or {}
    columns[i] = counts
    local c = line:sub(i, i)
    counts[c] = (counts[c] or 0) + 1
  end
end
file:close()

-- Each column's letter is its most common one (part 1) or its least common
-- one (part 2); ties go to the earlier letter so the output is stable.
local function decode(better)
  local message = {}
  for i, counts in ipairs(columns) do
    local best
    for c, n in pairs(counts) do
      if not best or better(n, counts[best]) or (n == counts[best] and c < best) then best = c end
    end
    message[i] = best
  end
  return table.concat(message)
end

print(decode(function(a, b) return a > b end))
print(decode(function(a, b) return a < b end))
