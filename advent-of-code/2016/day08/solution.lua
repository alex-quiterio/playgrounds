-- Day 8: Two-Factor Authentication
local file = assert(io.open(arg[1] or "", "r"), "usage: solution.lua INPUT")
local WIDTH, HEIGHT = 50, 6

local screen = {}
for y = 0, HEIGHT - 1 do
  screen[y] = {}
  for x = 0, WIDTH - 1 do screen[y][x] = false end
end

for line in file:lines() do
  local w, h = line:match("^rect (%d+)x(%d+)")
  local row, by_row = line:match("^rotate row y=(%d+) by (%d+)")
  local col, by_col = line:match("^rotate column x=(%d+) by (%d+)")
  if w then
    for y = 0, tonumber(h) - 1 do
      for x = 0, tonumber(w) - 1 do screen[y][x] = true end
    end
  elseif row then
    local y, old = tonumber(row), {}
    for x = 0, WIDTH - 1 do old[x] = screen[y][x] end
    for x = 0, WIDTH - 1 do screen[y][(x + by_row) % WIDTH] = old[x] end
  elseif col then
    local x, old = tonumber(col), {}
    for y = 0, HEIGHT - 1 do old[y] = screen[y][x] end
    for y = 0, HEIGHT - 1 do screen[(y + by_col) % HEIGHT][x] = old[y] end
  end
end
file:close()

local lit = 0
for y = 0, HEIGHT - 1 do
  for x = 0, WIDTH - 1 do if screen[y][x] then lit = lit + 1 end end
end

-- Part 2: the screen shows ten letters, each five columns wide (four lit
-- columns and a gap). Read them with the usual Advent of Code font; the
-- screen goes to stderr too, in case a letter is not in the table.
local FONT = {
  [".##.#..##..######..##..#"] = "A", ["###.#..####.#..##..####."] = "B",
  [".##.#..##...#...#..#.##."] = "C", ["#####...###.#...#...####"] = "E",
  ["#####...###.#...#...#..."] = "F", [".##.#..##...#.###..#.###"] = "G",
  ["#..##..######..##..##..#"] = "H", [".###..#...#...#...#..###"] = "I",
  ["..##...#...#...##..#.##."] = "J", ["#..##.#.##..#.#.#.#.#..#"] = "K",
  ["#...#...#...#...#...####"] = "L", [".##.#..##..##..##..#.##."] = "O",
  ["###.#..##..####.#...#..."] = "P", ["###.#..##..####.#.#.#..#"] = "R",
  [".####...#....##....####."] = "S", ["#..##..##..##..##..#.##."] = "U",
  ["#...#....#.#..#...#...#."] = "Y", ["####...#..#..#..#...####"] = "Z",
}
local text = {}
for left = 0, WIDTH - 1, 5 do
  local glyph = {}
  for y = 0, HEIGHT - 1 do
    for x = left, left + 3 do glyph[#glyph + 1] = screen[y][x] and "#" or "." end
  end
  text[#text + 1] = FONT[table.concat(glyph)] or "?"
end
for y = 0, HEIGHT - 1 do
  local row = {}
  for x = 0, WIDTH - 1 do row[#row + 1] = screen[y][x] and "#" or "." end
  io.stderr:write(table.concat(row), "\n")
end

print(lit)
print(table.concat(text))
