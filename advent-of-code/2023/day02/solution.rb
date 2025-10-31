# Day 2: Cube Conundrum
BAG = { 'red' => 12, 'green' => 13, 'blue' => 14 }.freeze

# The most cubes of each colour shown at once in a game.
def fewest_cubes(game)
  game.scan(/(\d+) (red|green|blue)/).each_with_object(Hash.new(0)) do |(count, colour), most|
    most[colour] = [most[colour], count.to_i].max
  end
end

games = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map do |line|
  [line[/Game (\d+)/, 1].to_i, fewest_cubes(line)]
end
puts games.select { |_, most| BAG.all? { |colour, n| most[colour] <= n } }.sum(&:first)
puts games.sum { |_, most| most.values_at('red', 'green', 'blue').reduce(:*) }
