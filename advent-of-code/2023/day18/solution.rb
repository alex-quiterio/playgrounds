# Day 18: Lavaduct Lagoon
STEPS = { 'R' => [0, 1], 'D' => [1, 0], 'L' => [0, -1], 'U' => [-1, 0] }.freeze

# Cubic metres dug: shoelace area for the interior plus the trench itself
# (Pick's theorem: inside + boundary = area + boundary / 2 + 1).
def lagoon(moves)
  r = c = 0
  area2 = 0
  boundary = 0
  moves.each do |direction, length|
    dr, dc = STEPS.fetch(direction)
    nr, nc = r + dr * length, c + dc * length
    area2 += c * nr - nc * r
    boundary += length
    r, c = nr, nc
  end
  area2.abs / 2 + boundary / 2 + 1
end

plan = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map(&:split)
puts lagoon(plan.map { |dir, length, _| [dir, length.to_i] })
# The colour is the real instruction: five hex digits of length, then the direction.
puts lagoon(plan.map { |_, _, colour| hex = colour[/\h{6}/]; ['RDLU'[hex[5].to_i], hex[0, 5].to_i(16)] })
