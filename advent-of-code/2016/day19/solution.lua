-- Day 19: An Elephant Named Joseph
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local n = tonumber(file:read("*a"):match("%d+"))
file:close()

-- Part 1 is the Josephus problem with every second elf out: write n as
-- 2^m + l and the winner is 2l + 1.
local power = 1
while power * 2 <= n do power = power * 2 end
print(2 * (n - power) + 1)

-- Part 2 steals from across the circle. Simulating small circles shows the
-- pattern: with 3^m the largest power of three at most n, the winner is n
-- when n = 3^m, n - 3^m up to 2 * 3^m, and 2n - 3^(m+1) after that.
power = 1
while power * 3 <= n do power = power * 3 end
if n == power then print(n)
elseif n <= 2 * power then print(n - power)
else print(2 * n - 3 * power) end
