# Day 14: Parabolic Reflector Dish

# Rolls every O as far west as it goes in each row.
def tilt_west(rows)
  rows.map { |row| row.split(/(#)/, -1).map { |part| part == '#' ? part : part.chars.sort.reverse.join }.join }
end

def tilt_north(rows) = tilt_west(rows.map(&:chars).transpose.map(&:join)).map(&:chars).transpose.map(&:join)

# One spin cycle: north, west, south, east. Rotating clockwise and tilting
# north four times does the same thing.
def spin(rows)
  4.times { rows = tilt_north(rows).map(&:chars).transpose.map(&:reverse).map(&:join) }
  rows
end

def load(rows) = rows.each_with_index.sum { |row, r| row.count('O') * (rows.size - r) }

dish = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
puts load(tilt_north(dish))

# The dish settles into a loop; skip ahead to the billionth cycle.
seen = {}
history = []
rows = dish
total = 1_000_000_000
(0..).each do |i|
  if seen.key?(rows)
    start = seen[rows]
    rows = history[start + (total - start) % (i - start)]
    break
  end
  seen[rows] = i
  history << rows
  rows = spin(rows)
end
puts load(rows)
