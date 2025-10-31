# Day 8: Haunted Wasteland
instructions, *lines = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
nodes = lines.to_h { |l| node, left, right = l.scan(/\w+/); [node, { 'L' => left, 'R' => right }] }

def steps(start, instructions, nodes)
  node = start
  instructions.chars.cycle.with_index(1) do |turn, i|
    node = nodes[node][turn]
    return i if yield(node)
  end
end

puts nodes.key?('AAA') ? steps('AAA', instructions, nodes) { |n| n == 'ZZZ' } : 0
# Every ghost loops back to its Z node on a fixed cycle, so they all meet at the LCM.
ghosts = nodes.keys.select { |n| n.end_with?('A') }
puts ghosts.map { |g| steps(g, instructions, nodes) { |n| n.end_with?('Z') } }.reduce(1, :lcm)
