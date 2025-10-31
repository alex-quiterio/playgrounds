# Day 6: Wait For It

# Number of ways to beat the record: holding h ms gives h * (time - h) mm.
# Solve h^2 - time*h + record < 0 and count the integers strictly inside.
def ways(time, record)
  root = Math.sqrt(time * time - 4 * record)
  low = ((time - root) / 2).floor + 1
  high = ((time + root) / 2).ceil - 1
  [high - low + 1, 0].max
end

times, records = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.scan(/\d+/) }
puts times.zip(records).map { |t, r| ways(t.to_i, r.to_i) }.reduce(:*)
puts ways(times.join.to_i, records.join.to_i)
