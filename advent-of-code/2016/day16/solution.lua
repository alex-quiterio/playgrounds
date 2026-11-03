-- Day 16: Dragon Checksum
-- The input is the initial state. The example adds its own disk length
-- after it ("10000 20"); the real disks are 272 and 35651584 long.
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local text = file:read("a")
file:close()
local initial = text:match("[01]+")
local example_length = tonumber(text:match("[01]+%s+(%d+)"))

local FLIP = { ["0"] = "1", ["1"] = "0" }

local function checksum(length)
  local data = initial
  while #data < length do
    data = data .. "0" .. data:reverse():gsub("[01]", FLIP)
  end
  data = data:sub(1, length)
  -- Folding pairs over and over turns each chunk of 2^k characters (the
  -- largest power of two dividing the length) into one character: "1" when
  -- the chunk holds an even number of ones. So count the ones per chunk.
  local chunk = length & -length
  local out = {}
  for start = 1, length, chunk do
    local piece = data:sub(start, start + chunk - 1)
    local ones = #piece - #piece:gsub("1", "")
    out[#out + 1] = ones % 2 == 0 and "1" or "0"
  end
  return table.concat(out)
end

if example_length then
  print(checksum(example_length))
else
  print(checksum(272))
  -- Part 2: the second disk.
  print(checksum(35651584))
end
