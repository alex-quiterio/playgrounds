# Day 20: Infinite Elves and Infinite Houses
target = File.read(ARGV.fetch(0)).to_i

# The first house getting at least `target` presents, when elf e brings
# `per_house * e` presents to e, 2e, 3e, ... (to its first `houses` stops).
# Sieve over a range of houses, doubling the range until a house qualifies.
def first_house(target, per_house, houses = nil)
  limit = 1024
  loop do
    presents = Array.new(limit + 1, 0)
    (1..limit).each do |elf|
      last = houses ? [elf * houses, limit].min : limit
      elf.step(last, elf) { |h| presents[h] += per_house * elf }
    end
    found = (1..limit).find { |h| presents[h] >= target }
    return found if found

    limit *= 2
  end
end

puts first_house(target, 10)
puts first_house(target, 11, 50)
