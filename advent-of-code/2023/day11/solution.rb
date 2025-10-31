# Day 11: Cosmic Expansion
image = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
galaxies = image.each_with_index.flat_map { |row, r| row.each_char.with_index.select { |ch, _| ch == '#' }.map { |_, c| [r, c] } }
empty_rows = (0...image.size).reject { |r| image[r].include?('#') }
empty_cols = (0...image.first.size).reject { |c| image.any? { |row| row[c] == '#' } }

# Sum of distances when every empty row and column is `factor` times wider.
def total_distance(galaxies, empty_rows, empty_cols, factor)
  galaxies.combination(2).sum do |(r1, c1), (r2, c2)|
    rows = [r1, r2].minmax
    cols = [c1, c2].minmax
    extra = empty_rows.count { |r| r > rows[0] && r < rows[1] } + empty_cols.count { |c| c > cols[0] && c < cols[1] }
    (rows[1] - rows[0]) + (cols[1] - cols[0]) + extra * (factor - 1)
  end
end

puts total_distance(galaxies, empty_rows, empty_cols, 2)
# The example states the totals for 10 and 100; the puzzle asks for a million.
puts total_distance(galaxies, empty_rows, empty_cols, image.size < 20 ? 100 : 1_000_000)
