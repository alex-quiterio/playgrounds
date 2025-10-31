# Day 7: Camel Cards

# Hand strength: the sorted group sizes, so [5] beats [4, 1] beats [3, 2] ...
def kind(cards, jokers)
  counts = cards.chars.tally
  wild = jokers ? counts.delete('J').to_i : 0
  groups = counts.values.sort.reverse
  groups = [0] if groups.empty? # JJJJJ
  groups[0] += wild
  groups
end

def winnings(hands, jokers)
  order = jokers ? 'J23456789TQKA' : '23456789TJQKA'
  ranked = hands.sort_by { |cards, _| [kind(cards, jokers), cards.chars.map { |c| order.index(c) }] }
  ranked.each_with_index.sum { |(_, bid), i| bid * (i + 1) }
end

hands = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| c, b = l.split; [c, b.to_i] }
puts winnings(hands, false)
puts winnings(hands, true)
