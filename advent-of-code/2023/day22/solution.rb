# Day 22: Sand Slabs
bricks = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.scan(/\d+/).map(&:to_i).each_slice(3).to_a }
bricks.sort_by! { |a, b| [a[2], b[2]].min }

# Let every brick fall; record which bricks rest on which.
height = Hash.new(0) # top z at each (x, y)
top_brick = {}       # brick on top at each (x, y)
supports = Array.new(bricks.size) { [] }
supported_by = Array.new(bricks.size) { [] }
bricks.each_with_index do |(a, b), i|
  cells = (a[0]..b[0]).to_a.product((a[1]..b[1]).to_a)
  z = cells.map { |xy| height[xy] }.max + 1
  below = cells.select { |xy| height[xy] == z - 1 && top_brick.key?(xy) }.map { |xy| top_brick[xy] }.uniq
  below.each { |j| supports[j] << i; supported_by[i] << j }
  top = z + (b[2] - a[2])
  cells.each { |xy| height[xy] = top; top_brick[xy] = i }
end

# Safe to remove: everything it holds up has another support.
puts (0...bricks.size).count { |i| supports[i].all? { |j| supported_by[j].size > 1 } }

# For each brick, how many others fall in the chain reaction.
falls = (0...bricks.size).sum do |i|
  fallen = { i => true }
  queue = [i]
  until queue.empty?
    supports[queue.shift].each do |j|
      next if fallen[j] || !supported_by[j].all? { |k| fallen[k] }

      fallen[j] = true
      queue << j
    end
  end
  fallen.size - 1
end
puts falls
