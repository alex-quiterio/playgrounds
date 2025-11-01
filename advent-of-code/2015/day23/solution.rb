# Day 23: Opening the Turing Lock
program = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.split(/,? /) }

# Runs the program and returns register b.
def run(program, a)
  regs = { 'a' => a, 'b' => 0 }
  pc = 0
  while (op, x, y = program[pc])
    case op
    when 'hlf' then regs[x] /= 2
    when 'tpl' then regs[x] *= 3
    when 'inc' then regs[x] += 1
    when 'jmp' then pc += x.to_i - 1
    when 'jie' then pc += y.to_i - 1 if regs[x].even?
    when 'jio' then pc += y.to_i - 1 if regs[x] == 1 # "one", not "odd"
    end
    pc += 1
  end
  regs['b']
end

puts run(program, 0)
puts run(program, 1)
