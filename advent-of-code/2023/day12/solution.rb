# Day 12: Hot Springs

# Ways to fill the ?s so the runs of # match the group sizes (memoised on position).
def arrangements(springs, groups)
  memo = {}
  count = lambda do |i, g|
    memo[[i, g]] ||= begin
      if g == groups.size
        (springs[i..] || '').include?('#') ? 0 : 1
      elsif i >= springs.size
        0
      else
        ways = 0
        ways += count.(i + 1, g) if springs[i] != '#' # leave this spring working
        size = groups[g]
        fits = i + size <= springs.size && !springs[i, size].include?('.') && springs[i + size] != '#'
        ways += count.(i + size + 1, g + 1) if springs[i] != '.' && fits
        ways
      end
    end
  end
  count.(0, 0)
end

rows = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map do |line|
  springs, groups = line.split
  [springs, groups.split(',').map(&:to_i)]
end
puts rows.sum { |springs, groups| arrangements(springs, groups) }
puts rows.sum { |springs, groups| arrangements(([springs] * 5).join('?'), groups * 5) }
