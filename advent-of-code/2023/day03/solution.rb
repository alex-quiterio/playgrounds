# Day 3: Gear Ratios
grid = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)

symbol = ->(r, c) { r.between?(0, grid.size - 1) && c.between?(0, grid[r].size - 1) && grid[r][c].match?(%r{[^\d.]}) }

part_numbers = 0
gears = Hash.new { |h, k| h[k] = [] }
grid.each_with_index do |row, r|
  row.to_enum(:scan, /\d+/).each do
    number = Regexp.last_match[0].to_i
    first, last = Regexp.last_match.begin(0), Regexp.last_match.end(0) - 1
    around = (r - 1..r + 1).to_a.product((first - 1..last + 1).to_a).select { |rr, cc| symbol.(rr, cc) }
    part_numbers += number unless around.empty?
    around.each { |rr, cc| gears[[rr, cc]] << number if grid[rr][cc] == '*' }
  end
end
puts part_numbers
puts gears.values.select { |numbers| numbers.size == 2 }.sum { |a, b| a * b }
