# Day 21: RPG Simulator 20XX
boss_hp, boss_damage, boss_armor = File.read(ARGV.fetch(0)).scan(/\d+/).map(&:to_i)

# [cost, damage, armor]
WEAPONS = [[8, 4, 0], [10, 5, 0], [25, 6, 0], [40, 7, 0], [74, 8, 0]].freeze
ARMOR = [[0, 0, 0], [13, 0, 1], [31, 0, 2], [53, 0, 3], [75, 0, 4], [102, 0, 5]].freeze
RINGS = [[25, 1, 0], [50, 2, 0], [100, 3, 0], [20, 0, 1], [40, 0, 2], [80, 0, 3]].freeze

# One weapon, at most one armor, at most two different rings.
loadouts = WEAPONS.product(ARMOR, (0..2).flat_map { |n| RINGS.combination(n).to_a }).map do |weapon, armor, rings|
  [weapon, armor, *rings].transpose.map(&:sum)
end

# Each hit does at least 1. We strike first, so we win when we need no
# more turns than the boss does.
win = lambda do |(_, damage, armor)|
  ours = (boss_hp.to_f / [damage - boss_armor, 1].max).ceil
  theirs = (100.0 / [boss_damage - armor, 1].max).ceil
  ours <= theirs
end

puts loadouts.select(&win).map(&:first).min
puts loadouts.reject(&win).map(&:first).max
