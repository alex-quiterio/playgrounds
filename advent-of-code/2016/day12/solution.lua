-- Day 12: Leonardo's Monorail
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local program = {}
for line in file:lines() do
  local words = {}
  for w in line:gmatch("%S+") do words[#words + 1] = w end
  if #words > 0 then program[#program + 1] = words end
end
file:close()

-- Runs the assembunny program and returns register a.
local function run(c)
  local reg = { a = 0, b = 0, c = c, d = 0 }
  local function value(x) return reg[x] or tonumber(x) end
  local pc = 1
  while pc <= #program do
    local op, x, y = program[pc][1], program[pc][2], program[pc][3]
    if op == "cpy" then reg[y] = value(x)
    elseif op == "inc" then reg[x] = reg[x] + 1
    elseif op == "dec" then reg[x] = reg[x] - 1
    elseif op == "jnz" and value(x) ~= 0 then pc = pc + tonumber(y) - 1 end
    pc = pc + 1
  end
  return reg.a
end

print(run(0))
-- Part 2: the ignition key sets register c to 1.
print(run(1))
