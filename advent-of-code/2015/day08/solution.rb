# Day 8: Matchsticks
lines = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)

# Characters in memory: drop the surrounding quotes, then each escape
# (\\, \" or \x plus two hex digits) is one character.
def in_memory(literal)
  literal[1...-1].gsub(/\\(\\|"|x[0-9a-f]{2})/, '.').length
end

# Encoding a literal again: quotes around it, and a backslash before every
# quote and backslash inside.
def encoded(literal)
  literal.length + 2 + literal.count('"\\')
end

puts lines.sum { |l| l.length - in_memory(l) }
puts lines.sum { |l| encoded(l) - l.length }
