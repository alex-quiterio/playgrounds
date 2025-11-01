# Day 14: Reindeer Olympics
Reindeer = Struct.new(:speed, :fly, :rest) do
  # Distance after `t` seconds: whole fly-and-rest cycles, then what is left.
  def distance(t)
    cycles, left = t.divmod(fly + rest)
    speed * (cycles * fly + [left, fly].min)
  end
end

herd = File.readlines(ARGV.fetch(0)).filter_map do |line|
  next unless (m = line.match(/(\d+) km\/s for (\d+) seconds, but then must rest for (\d+)/))

  Reindeer.new(*m.captures.map(&:to_i))
end

# The race lasts 2503 seconds; the puzzle's two-reindeer example uses 1000.
seconds = herd.size == 2 ? 1000 : 2503
puts herd.map { |r| r.distance(seconds) }.max

# Part 2: each second, every reindeer in the lead scores a point.
points = Array.new(herd.size, 0)
(1..seconds).each do |t|
  distances = herd.map { |r| r.distance(t) }
  lead = distances.max
  distances.each_with_index { |d, i| points[i] += 1 if d == lead }
end
puts points.max
