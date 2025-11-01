# Day 25: Let It Snow
row, column = File.read(ARGV.fetch(0)).scan(/\d+/).map(&:to_i)

# Codes fill the grid one diagonal at a time. The diagonal through (row,
# column) is number row + column - 1, and the codes before it fill a triangle.
diagonal = row + column - 1
index = diagonal * (diagonal - 1) / 2 + column

# Each code is the previous one times 252533, modulo 33554393.
puts 20_151_125 * 252_533.pow(index - 1, 33_554_393) % 33_554_393
