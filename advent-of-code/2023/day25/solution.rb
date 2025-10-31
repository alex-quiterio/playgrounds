# Day 25: Snowverload
EDGES = Hash.new { |h, k| h[k] = [] }
File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).each do |line|
  node, others = line.split(': ')
  others.split.each { |o| EDGES[node] << o; EDGES[o] << node }
end

# Unit-capacity max flow from s to t (Edmonds-Karp). Stops early above `limit`.
# Returns the flow and the nodes still reachable from s afterwards.
def max_flow(s, t, limit)
  flow = Hash.new(0)
  total = 0
  loop do
    parent = { s => nil }
    queue = [s]
    until queue.empty? || parent.key?(t)
      u = queue.shift
      EDGES[u].each do |v|
        next if parent.key?(v) || flow[[u, v]] >= 1

        parent[v] = u
        queue << v
      end
    end
    return [total, parent.keys] unless parent.key?(t)

    v = t
    while (u = parent[v])
      flow[[u, v]] += 1
      flow[[v, u]] -= 1
      v = u
    end
    total += 1
    return [total, nil] if total > limit
  end
end

# The two groups are joined by exactly three wires: find a node on the other
# side, where the minimum cut from the first node is 3.
source = EDGES.keys.first
EDGES.each_key do |sink|
  next if sink == source

  cut, side = max_flow(source, sink, 3)
  next unless cut == 3

  puts side.size * (EDGES.size - side.size)
  break
end
