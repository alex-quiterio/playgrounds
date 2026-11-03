-- Day 11: Radioisotope Thermoelectric Generators
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local FLOORS = { first = 1, second = 2, third = 3, fourth = 4 }

-- Each element is a pair: the floor of its generator and of its microchip.
local pairs_by_name, names = {}, {}
local function pair(name)
  if not pairs_by_name[name] then
    pairs_by_name[name] = {}
    names[#names + 1] = name
  end
  return pairs_by_name[name]
end
for line in file:lines() do
  local floor = FLOORS[line:match("^The (%a+) floor")]
  if floor then
    for name in line:gmatch("(%a+) generator") do pair(name)[1] = floor end
    for name in line:gmatch("(%a+)%-compatible microchip") do pair(name)[2] = floor end
  end
end
file:close()

-- A state is the elevator floor plus the sorted list of pairs. Which
-- element is which does not matter, only where its two parts are, so
-- sorting the pairs merges states that are the same up to renaming. That
-- is what keeps the search small.
local function key(elevator, items)
  local codes = {}
  for i = 1, #items, 2 do codes[#codes + 1] = items[i] * 4 + items[i + 1] end
  table.sort(codes)
  return elevator .. ":" .. table.concat(codes, ",")
end

-- items is a flat list: generator, chip, generator, chip, ...
local function safe(items)
  for chip = 2, #items, 2 do
    local floor = items[chip]
    if items[chip - 1] ~= floor then
      for gen = 1, #items, 2 do
        if items[gen] == floor then return false end
      end
    end
  end
  return true
end

local function solve(start)
  local seen = { [key(1, start)] = true }
  local frontier, steps = { { 1, start } }, 0
  while #frontier > 0 do
    local next_frontier = {}
    for _, state in ipairs(frontier) do
      local elevator, items = state[1], state[2]
      local done = true
      for _, f in ipairs(items) do if f ~= 4 then done = false; break end end
      if done then return steps end

      local here = {}
      for i, f in ipairs(items) do if f == elevator then here[#here + 1] = i end end
      for _, to in ipairs({ elevator + 1, elevator - 1 }) do
        if to >= 1 and to <= 4 then
          -- Carry one or two items from this floor.
          for a = 1, #here do
            for b = a, #here do
              local moved = {}
              for i, f in ipairs(items) do moved[i] = f end
              moved[here[a]], moved[here[b]] = to, to
              if safe(moved) then
                local k = key(to, moved)
                if not seen[k] then
                  seen[k] = true
                  next_frontier[#next_frontier + 1] = { to, moved }
                end
              end
            end
          end
        end
      end
    end
    frontier, steps = next_frontier, steps + 1
  end
end

local start = {}
for _, name in ipairs(names) do
  start[#start + 1] = pairs_by_name[name][1]
  start[#start + 1] = pairs_by_name[name][2]
end
print(solve(start))

-- Part 2: an elerium and a dilithium pair also start on the first floor.
for _ = 1, 4 do start[#start + 1] = 1 end
print(solve(start))
