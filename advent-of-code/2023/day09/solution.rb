# Day 9: Mirage Maintenance

# Next value: add up the last value of every row of differences.
def extrapolate(values)
  return 0 if values.all?(&:zero?)

  values.last + extrapolate(values.each_cons(2).map { |a, b| b - a })
end

histories = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.split.map(&:to_i) }
puts histories.sum { |h| extrapolate(h) }
puts histories.sum { |h| extrapolate(h.reverse) }
