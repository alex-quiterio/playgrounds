-- Day 5: How About a Nice Game of Chess?
local here = arg[0]:match("(.*/)") or "./"
package.path = here .. "../lib/?.lua;" .. package.path
local md5 = require("md5")
local bit = require("bit")
local band, bor, lshift, rshift, bswap = bit.band, bit.bor, bit.lshift, bit.rshift, bit.bswap

local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local door = file:read("*l"):match("%S+")
file:close()

-- Tens of millions of hashes, so no strings are made per hash: the message
-- (door ID, then the index in decimal) is kept as bytes, the index's digits
-- are counted up in place, and MD5's single block is filled straight from
-- them.
local bytes = {}
for i = 1, #door do bytes[i] = door:byte(i) end
local digits = { 48 } -- "0", most significant digit first

local M = md5.M
local function fill_block()
  for i = 0, 15 do M[i] = 0 end
  local function put(pos, value) -- pos counts bytes from 0
    local w = rshift(pos, 2)
    M[w] = bor(M[w], lshift(value, 8 * band(pos, 3)))
  end
  for i = 1, #bytes do put(i - 1, bytes[i]) end
  for i = 1, #digits do put(#bytes + i - 1, digits[i]) end
  local len = #bytes + #digits
  put(len, 0x80)
  M[14] = len * 8
end

local function next_index()
  local i = #digits
  while i >= 1 do
    if digits[i] < 57 then digits[i] = digits[i] + 1; return end
    digits[i] = 48
    i = i - 1
  end
  table.insert(digits, 1, 49)
end

-- An interesting hash starts with five zeros, so the first 20 bits of its
-- first word are 0; the 6th hex digit is the next nibble and the 7th the
-- one after it.
local first, second, found = {}, {}, 0
while found < 8 do
  fill_block()
  local head = bswap((md5.block(md5.A0, md5.B0, md5.C0, md5.D0)))
  if band(head, -4096) == 0 then
    local sixth, seventh = band(rshift(head, 8), 15), band(rshift(head, 4), 15)
    if #first < 8 then first[#first + 1] = string.format("%x", sixth) end
    -- Part 2: the 6th digit is a position, the 7th the character for it.
    if sixth < 8 and not second[sixth + 1] then
      second[sixth + 1] = string.format("%x", seventh)
      found = found + 1
    end
  end
  next_index()
end

print(table.concat(first))
print(table.concat(second))
