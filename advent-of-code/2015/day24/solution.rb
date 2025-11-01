# Day 24: It Hangs in the Balance
weights = File.readlines(ARGV.fetch(0)).filter_map { |l| Integer(l, exception: false) }

# Can `items` be split into `groups` groups each weighing `target`?
def splits?(items, groups, target)
  return items.sum == target if groups == 1

  (1..items.size).any? do |n|
    items.combination(n).any? { |g| g.sum == target && splits?(items - g, groups - 1, target) }
  end
end

# The passenger group should hold as few packages as possible, then have
# the smallest product; the rest must still split evenly.
def entanglement(weights, groups)
  target = weights.sum / groups
  (1..weights.size).each do |n|
    candidates = weights.combination(n).select { |g| g.sum == target }.sort_by { |g| g.reduce(:*) }
    best = candidates.find { |g| splits?(weights - g, groups - 1, target) }
    return best.reduce(:*) if best
  end
end

puts entanglement(weights, 3)
puts entanglement(weights, 4)
