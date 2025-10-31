# Day 4: Scratchcards
matches = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map do |line|
  winning, mine = line.split(':').last.split('|').map { |part| part.split.map(&:to_i) }
  (winning & mine).size
end

puts matches.sum { |m| m.zero? ? 0 : 2**(m - 1) }

# Each card wins copies of the next `m` cards.
copies = Array.new(matches.size, 1)
matches.each_with_index do |m, i|
  (i + 1..[i + m, matches.size - 1].min).each { |j| copies[j] += copies[i] }
end
puts copies.sum
