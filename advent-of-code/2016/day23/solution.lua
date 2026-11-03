-- Day 23: Safe Cracking
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local source = {}
for line in file:lines() do
  local words = {}
  for w in line:gmatch("%S+") do words[#words + 1] = w end
  if #words > 0 then source[#source + 1] = words end
end
file:close()

local TOGGLE = { inc = "dec", dec = "inc", tgl = "inc", jnz = "cpy", cpy = "jnz" }
local REGISTER = { a = true, b = true, c = true, d = true }

local function run(a)
  local program = {}
  for i, words in ipairs(source) do program[i] = { table.unpack(words) } end
  local reg = { a = a, b = 0, c = 0, d = 0 }
  local function value(x) return reg[x] or tonumber(x) end

  -- The program multiplies by repeated addition in nested loops:
  --   cpy B C / inc A / dec C / jnz C -2 / dec D / jnz D -5
  -- adds B * D to A and clears C and D. Spotting it at run time (after any
  -- toggles) turns part 2's billions of steps into a few thousand.
  local function multiply_at(pc)
    local p = {}
    for k = 0, 5 do
      p[k] = program[pc + k]
      if not p[k] then return false end
    end
    local b, c = p[0][2], p[0][3]
    local acc, d = p[1][2], p[4][2]
    if p[0][1] == "cpy" and p[1][1] == "inc" and p[2][1] == "dec" and p[2][2] == c
      and p[3][1] == "jnz" and p[3][2] == c and p[3][3] == "-2"
      and p[4][1] == "dec" and p[5][1] == "jnz" and p[5][2] == d and p[5][3] == "-5"
      and REGISTER[c] and REGISTER[d] and REGISTER[acc] and acc ~= c and acc ~= d then
      reg[acc] = reg[acc] + value(b) * reg[d]
      reg[c], reg[d] = 0, 0
      return true
    end
    return false
  end

  local pc = 1
  while pc >= 1 and pc <= #program do
    local ins = program[pc]
    local op, x, y = ins[1], ins[2], ins[3]
    if multiply_at(pc) then pc = pc + 6
    else
      if op == "cpy" then
        if REGISTER[y] then reg[y] = value(x) end
      elseif op == "inc" then
        if REGISTER[x] then reg[x] = reg[x] + 1 end
      elseif op == "dec" then
        if REGISTER[x] then reg[x] = reg[x] - 1 end
      elseif op == "jnz" then
        if value(x) ~= 0 then pc = pc + value(y) - 1 end
      elseif op == "tgl" then
        local target = program[pc + value(x)]
        if target then target[1] = TOGGLE[target[1]] end
      end
      pc = pc + 1
    end
  end
  return reg.a
end

print(run(7))
-- Part 2: twelve eggs.
print(run(12))
