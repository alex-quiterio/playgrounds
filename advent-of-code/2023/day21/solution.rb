# Day 21: Step Counter
GRID = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
SIZE = GRID.size
START = GRID.each_with_index.flat_map { |row, r| row.index('S') ? [[r, row.index('S')]] : [] }.first

# Garden plots reachable in exactly `steps` steps on the infinitely tiled map.
def reachable(steps)
  frontier = { START => true }
  steps.times do
    nxt = {}
    frontier.each_key do |r, c|
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dr, dc|
        nr, nc = r + dr, c + dc
        nxt[[nr, nc]] = true if GRID[nr % SIZE][nc % SIZE] != '#'
      end
    end
    frontier = nxt
  end
  frontier.size
end

example = SIZE < 20
puts reachable(example ? 6 : 64)
if example
  # The example has no clear lanes, so just count directly for 100 steps.
  puts reachable(100)
else
  # S sits in an empty row and column, so the count grows quadratically every
  # SIZE steps. Fit a quadratic through three points and extend it.
  target = 26_501_365
  offset = target % SIZE
  a, b, c = (0..2).map { |k| reachable(offset + k * SIZE) }
  n = target / SIZE
  puts a + n * (b - a) + n * (n - 1) / 2 * (c - 2 * b + a)
end
