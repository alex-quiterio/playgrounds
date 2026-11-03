-- Day 14: One-Time Pad
local here = arg[0]:match("(.*/)") or "./"
package.path = here .. "../lib/?.lua;" .. package.path
local md5 = require("md5")

local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local salt = file:read("*l"):match("%S+")
file:close()

-- Finds the index that produces the 64th key, hashing each index `times`
-- deep. Each hash is reduced to what the rules look at: its first triple
-- and the set of characters it has five in a row of. Hashes are cached,
-- since every one is looked at again by the 1000 indexes before it.
local function index_of_64th_key(times)
  local cache = {}
  local function info(i)
    local entry = cache[i]
    if not entry then
      local h = md5.stretch(salt .. i, times)
      local fives = {}
      for c in h:gmatch("(%x)%1%1%1%1") do fives[c] = true end
      entry = { triple = h:match("(%x)%1%1"), fives = fives }
      cache[i] = entry
    end
    return entry
  end

  local keys, i = 0, -1
  while keys < 64 do
    i = i + 1
    local c = info(i).triple
    if c then
      for j = i + 1, i + 1000 do
        if info(j).fives[c] then keys = keys + 1; break end
      end
    end
    cache[i] = nil
  end
  return i
end

print(index_of_64th_key(1))
-- Part 2: key stretching, 2016 extra rounds of hashing.
print(index_of_64th_key(2017))
