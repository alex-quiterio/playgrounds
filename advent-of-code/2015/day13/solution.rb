# Day 13: Knights of the Dinner Table
happiness = Hash.new(0)
File.foreach(ARGV.fetch(0)) do |line|
  next unless (m = line.match(/(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)/))

  happiness[[m[1], m[4]]] = m[3].to_i * (m[2] == 'gain' ? 1 : -1)
end

# The best total change around a round table. Seat the first guest
# anywhere, since rotating the table changes nothing, and try every order
# for the rest.
def best(guests, happiness)
  first, *rest = guests
  rest.permutation.map do |order|
    table = [first, *order]
    table.each_with_index.sum do |guest, i|
      neighbour = table[(i + 1) % table.size]
      happiness[[guest, neighbour]] + happiness[[neighbour, guest]]
    end
  end.max
end

guests = happiness.keys.flatten.uniq
puts best(guests, happiness)
# Part 2: add ourselves; every pair with us is worth 0, which Hash.new(0) gives.
puts best(guests + ['me'], happiness)
