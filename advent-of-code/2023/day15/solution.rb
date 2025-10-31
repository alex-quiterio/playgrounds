# Day 15: Lens Library
def hash_of(text) = text.each_byte.reduce(0) { |value, byte| (value + byte) * 17 % 256 }

steps = File.read(ARGV.fetch(0)).delete("\n").split(',')
puts steps.sum { |s| hash_of(s) }

# Each box keeps its lenses in insertion order; Ruby hashes do too.
boxes = Array.new(256) { {} }
steps.each do |step|
  label, focal = step.split(/[=-]/)
  if step.include?('=')
    boxes[hash_of(label)][label] = focal.to_i
  else
    boxes[hash_of(label)].delete(label)
  end
end
puts boxes.each_with_index.sum { |box, b| box.values.each_with_index.sum { |focal, slot| (b + 1) * (slot + 1) * focal } }
