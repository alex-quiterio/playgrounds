-- Day 25: Clock Signal
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local program = {}
for line in file:lines() do
  local words = {}
  for w in line:gmatch("%S+") do words[#words + 1] = w end
  if #words > 0 then program[#program + 1] = words end
end
file:close()

-- Runs the program with register a set, and says whether its first `want`
-- outputs are the clock signal 0, 1, 0, 1, ...
local function clock_signal(a, want)
  local reg = { a = a, b = 0, c = 0, d = 0 }
  local function value(x) return reg[x] or tonumber(x) end
  local pc, sent = 1, 0
  while pc >= 1 and pc <= #program do
    local op, x, y = program[pc][1], program[pc][2], program[pc][3]
    if op == "cpy" then reg[y] = value(x)
    elseif op == "inc" then reg[x] = reg[x] + 1
    elseif op == "dec" then reg[x] = reg[x] - 1
    elseif op == "jnz" and value(x) ~= 0 then pc = pc + value(y) - 1
    elseif op == "out" then
      if value(x) ~= sent % 2 then return false end
      sent = sent + 1
      if sent == want then return true end
    end
    pc = pc + 1
  end
  return false
end

-- The program prints the bits of a number over and over, so a few dozen
-- matching outputs cover several full repeats.
local a = 1
while not clock_signal(a, 40) do a = a + 1 end
print(a)
