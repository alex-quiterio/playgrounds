# Day 5: If You Give A Seed A Fertilizer
sections = File.read(ARGV.fetch(0)).split("\n\n")
seeds = sections.first.scan(/\d+/).map(&:to_i)
# Each map is a list of [source range, offset].
maps = sections.drop(1).map do |section|
  section.lines.drop(1).map(&:split).reject(&:empty?).map do |dest, source, length|
    dest, source, length = [dest, source, length].map(&:to_i)
    [source...source + length, dest - source]
  end
end

# Sends half-open ranges through one map, splitting them where rules start and stop.
def apply(ranges, map)
  ranges.flat_map do |range|
    pieces = []
    todo = [range]
    map.each do |rule, offset|
      todo = todo.flat_map do |r|
        overlap = [r.begin, rule.begin].max...[r.end, rule.end].min
        next [r] if overlap.begin >= overlap.end

        pieces << (overlap.begin + offset...overlap.end + offset)
        [(r.begin...overlap.begin), (overlap.end...r.end)].reject { |x| x.begin >= x.end }
      end
    end
    pieces + todo
  end
end

lowest = ->(ranges) { maps.reduce(ranges) { |rs, map| apply(rs, map) }.map(&:begin).min }
puts lowest.(seeds.map { |s| s...s + 1 })
puts lowest.(seeds.each_slice(2).map { |start, length| start...start + length })
