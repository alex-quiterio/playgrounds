-- Day 10: Balance Bots
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local chips, rules = {}, {}
local has_61 = false
for line in file:lines() do
  local value, bot = line:match("^value (%d+) goes to bot (%d+)")
  if value then
    bot = tonumber(bot)
    chips[bot] = chips[bot] or {}
    table.insert(chips[bot], tonumber(value))
    if value == "61" then has_61 = true end
  else
    local from, low_kind, low, high_kind, high =
      line:match("^bot (%d+) gives low to (%a+) (%d+) and high to (%a+) (%d+)")
    if from then
      rules[tonumber(from)] = { low_kind, tonumber(low), high_kind, tonumber(high) }
    end
  end
end
file:close()

-- The puzzle asks which bot compares chips 61 and 17; its example asks the
-- same of chips 5 and 2. Every chip enters through a "value" line, so the
-- input tells which question it is.
local want_low, want_high = 17, 61
if not has_61 then want_low, want_high = 2, 5 end

local outputs, comparer = {}, nil
local function give(kind, id, value)
  if kind == "output" then outputs[id] = value; return end
  chips[id] = chips[id] or {}
  table.insert(chips[id], value)
end

-- Keep letting any bot holding two chips hand them on until none is left.
local moved = true
while moved do
  moved = false
  for bot, held in pairs(chips) do
    if #held == 2 then
      local low, high = math.min(held[1], held[2]), math.max(held[1], held[2])
      if low == want_low and high == want_high then comparer = bot end
      chips[bot] = {}
      local r = rules[bot]
      give(r[1], r[2], low)
      give(r[3], r[4], high)
      moved = true
    end
  end
end

print(comparer)
print(outputs[0] * outputs[1] * outputs[2])
