-- Day 9: Explosives in Cyberspace
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local data = file:read("*a"):gsub("%s", "")
file:close()

-- Length of data[from..to] once decompressed. A marker (AxB) repeats the
-- next A characters B times; with `nested`, markers inside that span are
-- expanded too (part 2), otherwise they count as plain text (part 1).
local function length(from, to, nested)
  local total, i = 0, from
  while i <= to do
    local s, e, span, times = data:find("^%((%d+)x(%d+)%)", i)
    if s then
      span, times = tonumber(span), tonumber(times)
      local inner = nested and length(e + 1, e + span, true) or span
      total = total + inner * times
      i = e + span + 1
    else
      total, i = total + 1, i + 1
    end
  end
  return total
end

print(length(1, #data, false))
print(length(1, #data, true))
