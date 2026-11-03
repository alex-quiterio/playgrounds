-- Day 5: How About a Nice Game of Chess?
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local door = file:read("l"):match("%S+")
file:close()

-- MD5 for messages shorter than 56 bytes, which always fit in one block.
-- Lua has no MD5 of its own, so this is the RFC 1321 algorithm on 64-bit
-- integers masked to 32 bits.
local K, S = {}, {
  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
  5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
  4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
  6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
}
local G = {}
for i = 0, 63 do
  K[i + 1] = math.floor(math.abs(math.sin(i + 1)) * 2 ^ 32) & 0xffffffff
  if i < 16 then G[i + 1] = i
  elseif i < 32 then G[i + 1] = (5 * i + 1) % 16
  elseif i < 48 then G[i + 1] = (3 * i + 5) % 16
  else G[i + 1] = (7 * i) % 16 end
end

local M = {}
-- Returns the first 32 bits of the digest, as the big-endian number whose hex
-- form starts the hex digest: that is all this puzzle ever looks at.
local function md5_head(message)
  local len = #message
  local padded = message .. "\128" .. string.rep("\0", 55 - len)
  for i = 0, 13 do
    local b1, b2, b3, b4 = padded:byte(i * 4 + 1, i * 4 + 4)
    M[i] = b1 | (b2 << 8) | (b3 << 16) | (b4 << 24)
  end
  M[14], M[15] = (len * 8) & 0xffffffff, 0

  local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
  -- The four rounds differ only in how they mix b, c and d.
  for i = 1, 16 do
    local f = (((b & c) | (~b & d)) + a + K[i] + M[G[i]]) & 0xffffffff
    local s = S[i]
    a, d, c, b = d, c, b, (b + ((f << s) | (f >> (32 - s)))) & 0xffffffff
  end
  for i = 17, 32 do
    local f = (((d & b) | (~d & c)) + a + K[i] + M[G[i]]) & 0xffffffff
    local s = S[i]
    a, d, c, b = d, c, b, (b + ((f << s) | (f >> (32 - s)))) & 0xffffffff
  end
  for i = 33, 48 do
    local f = ((b ~ c ~ d) + a + K[i] + M[G[i]]) & 0xffffffff
    local s = S[i]
    a, d, c, b = d, c, b, (b + ((f << s) | (f >> (32 - s)))) & 0xffffffff
  end
  for i = 49, 64 do
    local f = (((c ~ (b | ~d)) & 0xffffffff) + a + K[i] + M[G[i]]) & 0xffffffff
    local s = S[i]
    a, d, c, b = d, c, b, (b + ((f << s) | (f >> (32 - s)))) & 0xffffffff
  end
  a = (a + 0x67452301) & 0xffffffff
  -- The digest stores `a` little-endian; flip it to read it as hex digits.
  return ((a & 0xff) << 24) | ((a & 0xff00) << 8) | ((a >> 8) & 0xff00) | (a >> 24)
end

-- An interesting hash starts with five zeros, so its first 20 bits are 0;
-- the 6th hex digit is the next nibble and the 7th the one after it.
local first, second, found = {}, {}, 0
local index = 0
while found < 8 do
  local head = md5_head(door .. index)
  if head < 0x1000 then
    local sixth, seventh = (head >> 8) & 0xf, (head >> 4) & 0xf
    local hex = string.format("%x", sixth)
    if #first < 8 then first[#first + 1] = hex end
    -- Part 2: the 6th digit is a position, the 7th the character for it.
    if sixth < 8 and not second[sixth + 1] then
      second[sixth + 1] = string.format("%x", seventh)
      found = found + 1
    end
  end
  index = index + 1
end

print(table.concat(first))
print(table.concat(second))
