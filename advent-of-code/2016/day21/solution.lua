-- Day 21: Scrambled Letters and Hash
-- Scrambles "abcdefgh" (part 1) and unscrambles "fbgdceah" (part 2). The
-- example sets its own starting password with a line "password abcde".
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local steps, password, scrambled = {}, "abcdefgh", "fbgdceah"
for line in file:lines() do
  local p = line:match("^password (%a+)$")
  if p then password = p elseif line ~= "" then steps[#steps + 1] = line end
end
file:close()

local function rotate_right(s, n)
  n = n % #s
  if n == 0 then return s end -- s:sub(-0) would be the whole string
  return s:sub(-n) .. s:sub(1, -n - 1)
end

local function scramble(s)
  for _, step in ipairs(steps) do
    local x, y = step:match("^swap position (%d+) with position (%d+)")
    if x then
      x, y = tonumber(x) + 1, tonumber(y) + 1
      local t = { s:byte(1, -1) }
      t[x], t[y] = t[y], t[x]
      s = string.char(table.unpack(t))
    end
    x, y = step:match("^swap letter (%a) with letter (%a)")
    if x then s = s:gsub("[" .. x .. y .. "]", { [x] = y, [y] = x }) end
    x, y = step:match("^rotate (%a+) (%d+) step")
    if x then s = rotate_right(s, x == "right" and tonumber(y) or -tonumber(y)) end
    x = step:match("^rotate based on position of letter (%a)")
    if x then
      local i = s:find(x, 1, true) - 1
      s = rotate_right(s, 1 + i + (i >= 4 and 1 or 0))
    end
    x, y = step:match("^reverse positions (%d+) through (%d+)")
    if x then
      x, y = tonumber(x) + 1, tonumber(y) + 1
      s = s:sub(1, x - 1) .. s:sub(x, y):reverse() .. s:sub(y + 1)
    end
    x, y = step:match("^move position (%d+) to position (%d+)")
    if x then
      x, y = tonumber(x) + 1, tonumber(y) + 1
      local c = s:sub(x, x)
      s = s:sub(1, x - 1) .. s:sub(x + 1)
      s = s:sub(1, y - 1) .. c .. s:sub(y)
    end
  end
  return s
end

print(scramble(password))

-- Part 2: "rotate based on position" is hard to undo, but eight letters
-- only have 40320 orders, so scramble each and keep the one that matches.
local function unscramble(target)
  local letters, used, chosen = {}, {}, {}
  for c in target:gmatch(".") do letters[#letters + 1] = c end
  local function try(depth)
    if depth > #letters then
      local candidate = table.concat(chosen)
      return scramble(candidate) == target and candidate or nil
    end
    for i, c in ipairs(letters) do
      if not used[i] then
        used[i], chosen[depth] = true, c
        local found = try(depth + 1)
        used[i] = false
        if found then return found end
      end
    end
  end
  return try(1)
end
print(unscramble(#password == #scrambled and scrambled or scramble(password)))
