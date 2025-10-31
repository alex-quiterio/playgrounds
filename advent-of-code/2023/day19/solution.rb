# Day 19: Aplenty
workflows_text, parts_text = File.read(ARGV.fetch(0)).split("\n\n")
WORKFLOWS = workflows_text.lines(chomp: true).reject(&:empty?).to_h do |line|
  name, rules = line.match(/(\w+)\{(.*)\}/).captures
  [name, rules.split(',').map { |rule| rule.include?(':') ? rule.match(/(\w)([<>])(\d+):(\w+)/).captures.then { |k, op, n, t| [k, op, n.to_i, t] } : [rule] }]
end

def accepted?(part, name = 'in')
  return name == 'A' if %w[A R].include?(name)

  WORKFLOWS[name].each do |rule|
    return accepted?(part, rule[0]) if rule.size == 1

    key, op, value, target = rule
    return accepted?(part, target) if op == '<' ? part[key] < value : part[key] > value
  end
end

parts = parts_text.lines(chomp: true).reject(&:empty?).map { |l| l.scan(/(\w)=(\d+)/).to_h { |k, v| [k, v.to_i] } }
puts parts.select { |p| accepted?(p) }.sum { |p| p.values.sum }

# Part 2: push ranges of ratings through the workflows, splitting at each rule.
def combinations(ranges, name = 'in')
  return 0 if name == 'R'
  return ranges.values.map(&:size).reduce(:*) if name == 'A'

  total = 0
  WORKFLOWS[name].each do |rule|
    return total + combinations(ranges, rule[0]) if rule.size == 1

    key, op, value, target = rule
    range = ranges[key]
    matching, rest = op == '<' ? [range.begin...[range.end, value].min, [range.begin, value].max...range.end]
                               : [[range.begin, value + 1].max...range.end, range.begin...[range.end, value + 1].min]
    total += combinations(ranges.merge(key => matching), target) if matching.size.positive?
    return total if rest.size.zero?

    ranges = ranges.merge(key => rest)
  end
  total
end
puts combinations(%w[x m a s].to_h { |k| [k, 1...4001] })
