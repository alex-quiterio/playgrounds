# Day 15: Science for Hungry People
ingredients = File.readlines(ARGV.fetch(0)).filter_map do |line|
  numbers = line.scan(/-?\d+/).map(&:to_i)
  numbers unless numbers.empty?
end

# Every way to split `total` teaspoons over `count` ingredients.
def splits(total, count)
  return [[total]] if count == 1

  (0..total).flat_map { |n| splits(total - n, count - 1).map { |rest| [n, *rest] } }
end

# A cookie's properties, with calories last, from teaspoons per ingredient.
cookies = splits(100, ingredients.size).map do |amounts|
  ingredients.transpose.map { |values| values.zip(amounts).sum { |v, n| v * n } }
end

# The score multiplies the four non-calorie properties; a negative total counts as 0.
score = ->(cookie) { cookie[0...-1].map { |p| [p, 0].max }.reduce(:*) }
puts cookies.map(&score).max
puts cookies.select { |c| c.last == 500 }.map(&score).max
