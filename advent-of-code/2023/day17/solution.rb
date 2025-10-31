# Day 17: Clumsy Crucible
GRID = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.chars.map(&:to_i) }

# A tiny binary heap of [cost, state] pairs.
class Heap
  def initialize = @items = []
  def empty? = @items.empty?

  def push(item)
    @items << item
    i = @items.size - 1
    while i.positive? && (@items[(i - 1) / 2] <=> item) == 1
      @items[i] = @items[(i - 1) / 2]
      i = (i - 1) / 2
    end
    @items[i] = item
  end

  def pop
    top = @items.first
    last = @items.pop
    unless @items.empty?
      i = 0
      loop do
        child = 2 * i + 1
        break if child >= @items.size

        child += 1 if child + 1 < @items.size && (@items[child + 1] <=> @items[child]) == -1
        break if (@items[child] <=> last) != -1

        @items[i] = @items[child]
        i = child
      end
      @items[i] = last
    end
    top
  end
end

# Least heat loss when the crucible must move between `min` and `max` blocks
# before turning. A state is (row, col, axis): the crucible just turned onto axis.
def least_heat_loss(min, max)
  rows, cols = GRID.size, GRID[0].size
  best = {}
  heap = Heap.new
  [[0, 0, 0], [0, 0, 1]].each { |s| best[s] = 0; heap.push([0, *s]) }
  until heap.empty?
    cost, r, c, axis = heap.pop
    return cost if r == rows - 1 && c == cols - 1
    next if cost > best[[r, c, axis]]

    # Move along the other axis, both ways, 1..max blocks.
    [-1, 1].each do |sign|
      dr, dc = axis.zero? ? [sign, 0] : [0, sign]
      loss = cost
      (1..max).each do |n|
        nr, nc = r + dr * n, c + dc * n
        break unless nr.between?(0, rows - 1) && nc.between?(0, cols - 1)

        loss += GRID[nr][nc]
        next if n < min

        state = [nr, nc, 1 - axis]
        if loss < best.fetch(state, Float::INFINITY)
          best[state] = loss
          heap.push([loss, *state])
        end
      end
    end
  end
end

puts least_heat_loss(1, 3)
puts least_heat_loss(4, 10)
