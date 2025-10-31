# Day 10: Pipe Maze
grid = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
PIPES = {
  '|' => [[-1, 0], [1, 0]], '-' => [[0, -1], [0, 1]],
  'L' => [[-1, 0], [0, 1]], 'J' => [[-1, 0], [0, -1]],
  '7' => [[1, 0], [0, -1]], 'F' => [[1, 0], [0, 1]]
}.freeze

at = ->(r, c) { r.between?(0, grid.size - 1) && c.between?(0, grid[r].size - 1) ? grid[r][c] : '.' }
start = grid.each_with_index.flat_map { |row, r| row.index('S') ? [[r, row.index('S')]] : [] }.first

# Work out the pipe under S from the neighbours that connect back to it.
links = [[-1, 0], [1, 0], [0, -1], [0, 1]].select do |dr, dc|
  (PIPES[at.(start[0] + dr, start[1] + dc)] || []).include?([-dr, -dc])
end
start_pipe = PIPES.key(links) || PIPES.key(links.reverse)
grid = grid.map(&:dup)
grid[start[0]][start[1]] = start_pipe

# Walk the loop.
loop_tiles = [start]
previous, current = start, [start[0] + links[0][0], start[1] + links[0][1]]
until current == start
  loop_tiles << current
  step = PIPES[grid[current[0]][current[1]]].map { |dr, dc| [current[0] + dr, current[1] + dc] }.find { |p| p != previous }
  previous, current = current, step
end
puts loop_tiles.size / 2

# Shoelace area plus Pick's theorem gives the tiles strictly inside the loop.
area = loop_tiles.zip(loop_tiles.rotate).sum { |(r1, c1), (r2, c2)| c1 * r2 - c2 * r1 }.abs / 2
puts area - loop_tiles.size / 2 + 1
