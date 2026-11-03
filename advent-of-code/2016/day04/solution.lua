-- Day 4: Security Through Obscurity
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")

-- The checksum is the five most common letters of the name, ties broken
-- alphabetically.
local function checksum(name)
  local counts = {}
  for c in name:gmatch("%a") do counts[c] = (counts[c] or 0) + 1 end
  local letters = {}
  for c in pairs(counts) do letters[#letters + 1] = c end
  table.sort(letters, function(a, b)
    if counts[a] ~= counts[b] then return counts[a] > counts[b] end
    return a < b
  end)
  return table.concat(letters, "", 1, math.min(5, #letters))
end

-- Part 2: shift every letter forward by the sector ID; dashes become spaces.
local function decrypt(name, sector)
  return (name:gsub("%a", function(c)
    return string.char((c:byte() - 97 + sector) % 26 + 97)
  end):gsub("-", " "))
end

local sum, north_pole = 0, "none"
for line in file:lines() do
  local name, sector, sum_check = line:match("^([%a-]+)-(%d+)%[(%a+)%]$")
  if name then
    sector = tonumber(sector)
    if checksum(name) == sum_check then
      sum = sum + sector
      if decrypt(name, sector):find("northpole") then north_pole = sector end
    end
  end
end
file:close()

print(sum)
print(north_pole)
