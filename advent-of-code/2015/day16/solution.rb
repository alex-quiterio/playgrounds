# Day 16: Aunt Sue

# What the MFCSAM read off the gift.
TICKER = {
  'children' => 3, 'cats' => 7, 'samoyeds' => 2, 'pomeranians' => 3, 'akitas' => 0,
  'vizslas' => 0, 'goldfish' => 5, 'trees' => 3, 'cars' => 2, 'perfumes' => 1
}.freeze

# Part 2: the cats and trees readings are lower limits, and the
# pomeranians and goldfish readings are upper limits.
RANGES = { 'cats' => :>, 'trees' => :>, 'pomeranians' => :<, 'goldfish' => :< }.freeze

aunts = File.readlines(ARGV.fetch(0)).filter_map do |line|
  next unless (m = line.match(/^Sue (\d+): (.*)$/))

  [m[1].to_i, m[2].scan(/(\w+): (\d+)/).to_h { |k, v| [k, v.to_i] }]
end

# The Sue whose every remembered thing agrees with the ticker. Anything we
# do not remember about her could be anything.
def find(aunts, ranges)
  aunts.find do |_, things|
    things.all? { |thing, n| n.send(ranges.fetch(thing, :==), TICKER.fetch(thing)) }
  end&.first
end

puts find(aunts, {})
puts find(aunts, RANGES)
