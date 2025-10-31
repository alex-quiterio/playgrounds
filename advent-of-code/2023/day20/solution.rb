# Day 20: Pulse Propagation
lines = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?)
TYPES = {}
OUTPUTS = {}
lines.each do |line|
  source, targets = line.split(' -> ')
  name = source.delete('%&')
  TYPES[name] = source[0] if '%&'.include?(source[0])
  OUTPUTS[name] = targets.split(', ')
end

def fresh_state
  flips = Hash.new(false)
  memory = Hash.new { |h, k| h[k] = {} }
  OUTPUTS.each { |src, targets| targets.each { |t| memory[t][src] = false if TYPES[t] == '&' } }
  [flips, memory]
end

# Presses the button once. Yields every pulse as (source, high, target).
def press(flips, memory)
  queue = [['button', false, 'broadcaster']]
  until queue.empty?
    source, high, target = queue.shift
    yield source, high, target
    out = case TYPES[target]
          when '%'
            next if high

            flips[target] = !flips[target]
          when '&'
            memory[target][source] = high
            !memory[target].values.all?
          else
            next unless OUTPUTS.key?(target)

            high
          end
    OUTPUTS[target].each { |t| queue << [target, out, t] }
  end
end

flips, memory = fresh_state
counts = [0, 0]
1000.times { press(flips, memory) { |_, high, _| counts[high ? 1 : 0] += 1 } }
puts counts.reduce(:*)

# rx is fed by one conjunction, which is fed by several sub-circuits. Each sends
# a high pulse on its own cycle; rx gets a low pulse when they line up (LCM).
feeder = OUTPUTS.find { |_, targets| targets.include?('rx') }&.first
if feeder
  watched = OUTPUTS.select { |_, targets| targets.include?(feeder) }.keys
  cycles = {}
  flips, memory = fresh_state
  (1..).each do |n|
    press(flips, memory) { |src, high, target| cycles[src] ||= n if high && target == feeder }
    break if watched.all? { |w| cycles[w] }
  end
  puts watched.map { |w| cycles[w] }.reduce(1, :lcm)
else
  puts 0
end
