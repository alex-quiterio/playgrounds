-- MD5 (RFC 1321) for LuaJIT, used by days 5, 14 and 17. Lua has no MD5 of
-- its own. LuaJIT's `bit` library works on 32-bit integers, which is what
-- MD5 is made of; `tobit` wraps each sum back into 32 bits.
local bit = require("bit")
local band, bor, bxor, bnot = bit.band, bit.bor, bit.bxor, bit.bnot
local lshift, rshift, rol, tobit = bit.lshift, bit.rshift, bit.rol, bit.tobit
local bswap, tohex = bit.bswap, bit.tohex
local byte = string.byte

local K, S, G = {}, {
  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
  5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
  4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
  6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
}, {}
for i = 0, 63 do
  K[i + 1] = tobit(math.floor(math.abs(math.sin(i + 1)) * 2 ^ 32) % 2 ^ 32)
  if i < 16 then G[i + 1] = i
  elseif i < 32 then G[i + 1] = (5 * i + 1) % 16
  elseif i < 48 then G[i + 1] = (3 * i + 5) % 16
  else G[i + 1] = (7 * i) % 16 end
end

local A0, B0, C0, D0 = tobit(0x67452301), tobit(0xefcdab89), tobit(0x98badcfe), tobit(0x10325476)

-- The 16 little-endian words of the block being hashed, M[0] to M[15].
local M = {}

-- Hashes the block in M into the state a, b, c, d and returns the new state.
local function block(a0, b0, c0, d0)
  local a, b, c, d = a0, b0, c0, d0
  for i = 1, 16 do
    local f = tobit(bor(band(b, c), band(bnot(b), d)) + a + K[i] + M[G[i]])
    a, d, c, b = d, c, b, tobit(b + rol(f, S[i]))
  end
  for i = 17, 32 do
    local f = tobit(bor(band(d, b), band(bnot(d), c)) + a + K[i] + M[G[i]])
    a, d, c, b = d, c, b, tobit(b + rol(f, S[i]))
  end
  for i = 33, 48 do
    local f = tobit(bxor(b, c, d) + a + K[i] + M[G[i]])
    a, d, c, b = d, c, b, tobit(b + rol(f, S[i]))
  end
  for i = 49, 64 do
    local f = tobit(bxor(c, bor(b, bnot(d))) + a + K[i] + M[G[i]])
    a, d, c, b = d, c, b, tobit(b + rol(f, S[i]))
  end
  return tobit(a0 + a), tobit(b0 + b), tobit(c0 + c), tobit(d0 + d)
end

-- The digest as four words, still in MD5's little-endian byte order.
local function digest(message)
  local len = #message
  local padded = message .. "\128" .. string.rep("\0", (55 - len) % 64)
  local bits = len * 8
  for k = 0, 7 do padded = padded .. string.char(math.floor(bits / 2 ^ (8 * k)) % 256) end
  local a, b, c, d = A0, B0, C0, D0
  for start = 1, #padded, 64 do
    for i = 0, 15 do
      local b1, b2, b3, b4 = byte(padded, start + i * 4, start + i * 4 + 3)
      M[i] = bor(b1, lshift(b2, 8), lshift(b3, 16), lshift(b4, 24))
    end
    a, b, c, d = block(a, b, c, d)
  end
  return a, b, c, d
end

local function to_hex(a, b, c, d)
  return tohex(bswap(a)) .. tohex(bswap(b)) .. tohex(bswap(c)) .. tohex(bswap(d))
end

-- The lowercase hex digest of a string.
local function hex(message)
  return to_hex(digest(message))
end

-- Each byte as its two lowercase hex digits, packed little-endian into 16 bits.
local PAIR = {}
for v = 0, 255 do
  local h = string.format("%02x", v)
  PAIR[v] = bor(byte(h, 1), lshift(byte(h, 2), 8))
end

-- The two message words that spell out word w of a digest in hex.
local function hex_words(w)
  return bor(PAIR[band(w, 255)], lshift(PAIR[band(rshift(w, 8), 255)], 16)),
    bor(PAIR[band(rshift(w, 16), 255)], lshift(PAIR[rshift(w, 24)], 16))
end

-- hex(hex(...hex(message))), `times` deep. After the first round the input
-- is always a 32-digit hex string, so its words are built straight from
-- the previous digest without making any strings.
local function stretch(message, times)
  local a, b, c, d = digest(message)
  for _ = 2, times do
    M[0], M[1] = hex_words(a)
    M[2], M[3] = hex_words(b)
    M[4], M[5] = hex_words(c)
    M[6], M[7] = hex_words(d)
    M[8], M[9], M[10], M[11], M[12], M[13], M[14], M[15] = 0x80, 0, 0, 0, 0, 0, 256, 0
    a, b, c, d = block(A0, B0, C0, D0)
  end
  return to_hex(a, b, c, d)
end

return {
  hex = hex,
  stretch = stretch,
  -- For callers that build the block themselves (day 5): fill M, then call
  -- block(md5.A0, md5.B0, md5.C0, md5.D0).
  M = M, block = block, A0 = A0, B0 = B0, C0 = C0, D0 = D0,
}
