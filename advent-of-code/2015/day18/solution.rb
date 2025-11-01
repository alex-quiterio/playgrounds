# Day 18: Like a GIF For Your Yard
require 'set'

start = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
SIZE = start.size
# 100 steps on the real 100x100 yard; the puzzle's 6x6 example shows 4 steps,
# and 5 for part 2.
STEPS = SIZE == 6 ? [4, 5] : [100, 100]
CORNERS = [[0, 0], [0, SIZE - 1], [SIZE - 1, 0], [SIZE - 1, SIZE - 1]].to_set

on = start.each_with_index.flat_map do |row, y|
  row.each_char.with_index.filter_map { |c, x| [x, y] if c == '#' }
end.to_set

# A light stays on with 2 or 3 neighbours on, and turns on with exactly 3.
def animate(on, steps, stuck)
  on |= stuck
  steps.times do
    counts = Hash.new(0)
    on.each do |x, y|
      [-1, 0, 1].product([-1, 0, 1]).each do |dx, dy|
        next if dx.zero? && dy.zero?

        nx, ny = x + dx, y + dy
        counts[[nx, ny]] += 1 if nx.between?(0, SIZE - 1) && ny.between?(0, SIZE - 1)
      end
    end
    on = counts.filter_map { |p, n| p if n == 3 || (n == 2 && on.include?(p)) }.to_set | stuck
  end
  on.size
end

puts animate(on, STEPS[0], Set.new)
# Part 2: the four corner lights are stuck on.
puts animate(on, STEPS[1], CORNERS)
