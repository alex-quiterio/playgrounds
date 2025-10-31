# Day 16: The Floor Will Be Lava
GRID = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)

# Directions a beam takes after entering a tile while moving (dr, dc).
def turns(tile, dr, dc)
  case tile
  when '/' then [[-dc, -dr]]
  when '\\' then [[dc, dr]]
  when '|' then dc.zero? ? [[dr, dc]] : [[-1, 0], [1, 0]]
  when '-' then dr.zero? ? [[dr, dc]] : [[0, -1], [0, 1]]
  else [[dr, dc]]
  end
end

# Tiles energised by a beam entering at (r, c) moving (dr, dc).
def energised(start)
  seen = {}
  stack = [start]
  until stack.empty?
    r, c, dr, dc = stack.pop
    next unless r.between?(0, GRID.size - 1) && c.between?(0, GRID[0].size - 1)
    next if seen[[r, c, dr, dc]]

    seen[[r, c, dr, dc]] = true
    turns(GRID[r][c], dr, dc).each { |nr, nc| stack << [r + nr, c + nc, nr, nc] }
  end
  seen.keys.map { |r, c, _, _| [r, c] }.uniq.size
end

rows, cols = GRID.size, GRID[0].size
puts energised([0, 0, 0, 1])
edges = (0...rows).flat_map { |r| [[r, 0, 0, 1], [r, cols - 1, 0, -1]] } +
        (0...cols).flat_map { |c| [[0, c, 1, 0], [rows - 1, c, -1, 0]] }
puts edges.map { |e| energised(e) }.max
