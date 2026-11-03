-- Day 7: Internet Protocol Version 7
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")

-- Splits an address into its supernet parts (outside brackets) and its
-- hypernet parts (inside brackets).
local function split(address)
  local supernets, hypernets = {}, {}
  for part in (address .. "["):gmatch("([^%[%]]*)[%[%]]") do
    -- Parts alternate: outside, inside, outside, ...
    if (#supernets + #hypernets) % 2 == 0 then supernets[#supernets + 1] = part
    else hypernets[#hypernets + 1] = part end
  end
  return supernets, hypernets
end

local function has_abba(s)
  for i = 1, #s - 3 do
    local a, b = s:sub(i, i), s:sub(i + 1, i + 1)
    if a ~= b and s:sub(i + 2, i + 2) == b and s:sub(i + 3, i + 3) == a then return true end
  end
  return false
end

local function any(parts, test)
  for _, p in ipairs(parts) do if test(p) then return true end end
  return false
end

local function supports_tls(supernets, hypernets)
  return any(supernets, has_abba) and not any(hypernets, has_abba)
end

-- Part 2: an ABA outside brackets with its BAB inside them.
local function supports_ssl(supernets, hypernets)
  for _, s in ipairs(supernets) do
    for i = 1, #s - 2 do
      local a, b = s:sub(i, i), s:sub(i + 1, i + 1)
      if a ~= b and s:sub(i + 2, i + 2) == a then
        local bab = b .. a .. b
        if any(hypernets, function(h) return h:find(bab, 1, true) end) then return true end
      end
    end
  end
  return false
end

local tls, ssl = 0, 0
for line in file:lines() do
  if line ~= "" then
    local supernets, hypernets = split(line)
    if supports_tls(supernets, hypernets) then tls = tls + 1 end
    if supports_ssl(supernets, hypernets) then ssl = ssl + 1 end
  end
end
file:close()

print(tls)
print(ssl)
