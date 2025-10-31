# Day 13: Point of Incidence

# Rows above a horizontal mirror whose reflection differs in exactly `smudges` cells.
def mirror_row(pattern, smudges)
  (1...pattern.size).find do |row|
    above = pattern[0...row].reverse
    below = pattern[row..]
    above.zip(below).sum { |a, b| b ? a.chars.zip(b.chars).count { |x, y| x != y } : 0 } == smudges
  end
end

def summary(pattern, smudges)
  columns = pattern.map(&:chars).transpose.map(&:join)
  (mirror_row(pattern, smudges) || 0) * 100 + (mirror_row(columns, smudges) || 0)
end

patterns = File.read(ARGV.fetch(0)).split("\n\n").map { |block| block.lines(chomp: true).reject(&:empty?) }
puts patterns.sum { |p| summary(p, 0) }
puts patterns.sum { |p| summary(p, 1) }
