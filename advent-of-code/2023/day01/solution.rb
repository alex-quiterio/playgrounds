# Day 1: Trebuchet?!
WORDS = %w[one two three four five six seven eight nine].each_with_index.to_h { |w, i| [w, i + 1] }

# First and last digit of a line; with words, spelled-out digits count too.
# Matching at every position handles overlaps such as "eightwo".
def calibration(line, words:)
  digits = line.each_char.with_index.filter_map do |char, i|
    next char.to_i if char.match?(/\d/)
    next unless words

    WORDS.find { |word, _| line[i..].start_with?(word) }&.last
  end
  digits.empty? ? 0 : digits.first * 10 + digits.last
end

lines = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
puts lines.sum { |l| calibration(l, words: false) }
puts lines.sum { |l| calibration(l, words: true) }
