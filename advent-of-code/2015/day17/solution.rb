# Day 17: No Such Thing as Too Much
containers = File.readlines(ARGV.fetch(0)).filter_map { |l| Integer(l, exception: false) }

# The eggnog is 150 liters; the puzzle's five-container example uses 25.
liters = containers.size == 5 ? 25 : 150

# Every combination that fills exactly `liters`, as its number of containers.
# Equal-sized containers are different containers, so pick by position.
fits = (1..containers.size).flat_map do |n|
  containers.combination(n).select { |picked| picked.sum == liters }.map(&:size)
end

puts fits.size
puts fits.count(fits.min)
