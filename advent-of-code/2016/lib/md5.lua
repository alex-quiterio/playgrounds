-- MD5 (RFC 1321) in plain Lua 5.4+, for the 2016 puzzles that need it.
-- Lua has no MD5 of its own. Integers are 64-bit, so every sum is masked
-- back to 32 bits.
local K, S, G = {}, {
  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
  5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
  4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
  6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
}, {}
for i = 0, 63 do
  K[i + 1] = math.floor(math.abs(math.sin(i + 1)) * 2 ^ 32) & 0xffffffff
  if i < 16 then G[i + 1] = i
  elseif i < 32 then G[i + 1] = (5 * i + 1) % 16
  elseif i < 48 then G[i + 1] = (3 * i + 5) % 16
  else G[i + 1] = (7 * i) % 16 end
end

local M = {}
local function block(a0, b0, c0, d0)
  local a, b, c, d = a0, b0, c0, d0
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
  return (a0 + a) & 0xffffffff, (b0 + b) & 0xffffffff, (c0 + c) & 0xffffffff, (d0 + d) & 0xffffffff
end

local function swap(w)
  return ((w & 0xff) << 24) | ((w & 0xff00) << 8) | ((w >> 8) & 0xff00) | (w >> 24)
end

-- The lowercase hex digest of a string.
local function hex(message)
  local len = #message
  local padded = message .. "\128" .. string.rep("\0", (55 - len) % 64)
    .. string.pack("<I8", len * 8)
  local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
  for start = 1, #padded, 64 do
    for i = 0, 15 do M[i] = string.unpack("<I4", padded, start + i * 4) end
    a, b, c, d = block(a, b, c, d)
  end
  return string.format("%08x%08x%08x%08x", swap(a), swap(b), swap(c), swap(d))
end

-- Each byte as its two lowercase hex digits, packed little-endian into 16 bits.
local PAIR = {}
for v = 0, 255 do
  local h = string.format("%02x", v)
  PAIR[v] = h:byte(1) | (h:byte(2) << 8)
end

-- hex(hex(...hex(message))), `times` deep. After the first round the input
-- is always a 32-digit hex string, so its words are built straight from
-- the previous digest without making any strings.
local function stretch(message, times)
  local h = hex(message)
  if times <= 1 then return h end
  local a, b, c, d = string.unpack("<I4<I4<I4<I4", (h:gsub("..", function(x) return string.char(tonumber(x, 16)) end)))
  for _ = 2, times do
    M[0], M[1] = PAIR[a & 255] | (PAIR[(a >> 8) & 255] << 16), PAIR[(a >> 16) & 255] | (PAIR[a >> 24] << 16)
    M[2], M[3] = PAIR[b & 255] | (PAIR[(b >> 8) & 255] << 16), PAIR[(b >> 16) & 255] | (PAIR[b >> 24] << 16)
    M[4], M[5] = PAIR[c & 255] | (PAIR[(c >> 8) & 255] << 16), PAIR[(c >> 16) & 255] | (PAIR[c >> 24] << 16)
    M[6], M[7] = PAIR[d & 255] | (PAIR[(d >> 8) & 255] << 16), PAIR[(d >> 16) & 255] | (PAIR[d >> 24] << 16)
    M[8], M[9], M[10], M[11], M[12], M[13], M[14], M[15] = 0x80, 0, 0, 0, 0, 0, 256, 0
    a, b, c, d = block(0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476)
  end
  return string.format("%08x%08x%08x%08x", swap(a), swap(b), swap(c), swap(d))
end

return { hex = hex, stretch = stretch }
