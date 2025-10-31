# Day 23: A Long Walk
GRID = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
ROWS, COLS = GRID.size, GRID[0].size
START = [0, GRID[0].index('.')]
GOAL = [ROWS - 1, GRID[-1].index('.')]
SLOPES = { '^' => [-1, 0], 'v' => [1, 0], '<' => [0, -1], '>' => [0, 1] }.freeze

def open?(r, c) = r.between?(0, ROWS - 1) && c.between?(0, COLS - 1) && GRID[r][c] != '#'

def moves(r, c, slippery)
  return [SLOPES[GRID[r][c]]] if slippery && SLOPES.key?(GRID[r][c])

  SLOPES.values
end

# Collapse the corridors into a graph of junctions with path lengths.
def junction_graph(slippery)
  junctions = [START, GOAL]
  (0...ROWS).each do |r|
    (0...COLS).each do |c|
      next unless open?(r, c)

      junctions << [r, c] if SLOPES.values.count { |dr, dc| open?(r + dr, c + dc) } >= 3
    end
  end
  index = junctions.each_with_index.to_h
  edges = Array.new(junctions.size) { [] }
  junctions.each_with_index do |from, i|
    stack = [[from, 0]]
    seen = { from => true }
    until stack.empty?
      (r, c), dist = stack.pop
      if dist.positive? && index.key?([r, c])
        edges[i] << [index[[r, c]], dist]
        next
      end
      moves(r, c, slippery).each do |dr, dc|
        nxt = [r + dr, c + dc]
        next if !open?(*nxt) || seen[nxt]

        seen[nxt] = true
        stack << [nxt, dist + 1]
      end
    end
  end
  edges
end

# Longest simple path from START (0) to GOAL (1), by depth-first search with a bitmask.
def longest(edges)
  best = 0
  stack = [[0, 1, 0]]
  until stack.empty?
    node, visited, dist = stack.pop
    if node == 1
      best = dist if dist > best
      next
    end
    edges[node].each do |nxt, length|
      stack << [nxt, visited | (1 << nxt), dist + length] if (visited >> nxt) & 1 == 0
    end
  end
  best
end

puts longest(junction_graph(true))
puts longest(junction_graph(false))
