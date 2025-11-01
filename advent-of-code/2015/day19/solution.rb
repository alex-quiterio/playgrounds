# Day 19: Medicine for Rudolph
lines = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
molecule = lines.pop
rules = lines.map { |l| l.split(' => ') }

# Part 1: every distinct molecule one replacement away.
made = rules.flat_map do |from, to|
  positions = (0...molecule.size).select { |i| molecule[i, from.size] == from }
  positions.map { |i| molecule[0...i] + to + molecule[(i + from.size)..] }
end
puts made.uniq.size

# Part 2 (real inputs only: the example's grammar is different). Every rule
# either turns one element into two, or has the shape X => A Rn B Ar,
# X => A Rn B Y C Ar, or X => A Rn B Y C Y D Ar. Rn and Ar come free with
# their rule and each Y brings one more element, so working back to the
# single "e" takes elements - Rn - Ar - 2 * Y - 1 steps.
if rules.any? { |_, to| to.include?('Rn') }
  elements = molecule.scan(/[A-Z][a-z]?/)
  puts elements.size - elements.count('Rn') - elements.count('Ar') - 2 * elements.count('Y') - 1
end
