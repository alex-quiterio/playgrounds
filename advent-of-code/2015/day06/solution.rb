# Day 6: Probably a Fire Hazard
SIZE = 1000

steps = File.readlines(ARGV.fetch(0), chomp: true).filter_map do |line|
  next unless (m = line.match(/(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/))

  [m[1], *m.captures.drop(1).map(&:to_i)]
end

# Part 1: each row of lights is one Integer used as a bitmask, so an
# instruction is a single bit operation per row.
rows = Array.new(SIZE, 0)
steps.each do |action, x1, y1, x2, y2|
  mask = ((1 << (x2 - x1 + 1)) - 1) << x1
  (y1..y2).each do |y|
    rows[y] = case action
              when 'turn on' then rows[y] | mask
              when 'turn off' then rows[y] & ~mask
              else rows[y] ^ mask
              end
  end
end
puts rows.sum { |row| row.to_s(2).count('1') }

# Part 2: brightness goes up by 1 or 2 and down by 1, never below 0.
grid = Array.new(SIZE) { Array.new(SIZE, 0) }
steps.each do |action, x1, y1, x2, y2|
  (y1..y2).each do |y|
    row = grid[y]
    case action
    when 'turn on' then (x1..x2).each { |x| row[x] += 1 }
    when 'turn off' then (x1..x2).each { |x| row[x] -= 1 if row[x].positive? }
    else (x1..x2).each { |x| row[x] += 2 }
    end
  end
end
puts grid.sum(&:sum)
