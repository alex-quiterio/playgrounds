# Day 22: Wizard Simulator 20XX
BOSS_HP, BOSS_DAMAGE = File.read(ARGV.fetch(0)).scan(/\d+/).map(&:to_i)

State = Struct.new(:hp, :mana, :boss, :shield, :poison, :recharge)

# [name, cost]; shield, poison and recharge are also the effects' timers.
SPELLS = [[:missile, 53], [:drain, 73], [:shield, 113], [:poison, 173], [:recharge, 229]].freeze

# Applies the active effects at the start of a turn; returns the armor.
def tick(s)
  armor = s.shield.positive? ? 7 : 0
  s.boss -= 3 if s.poison.positive?
  s.mana += 101 if s.recharge.positive?
  s.shield -= 1 if s.shield.positive?
  s.poison -= 1 if s.poison.positive?
  s.recharge -= 1 if s.recharge.positive?
  armor
end

# Plays our turn with `spell` and the boss's turn after it. Returns the new
# state, :won, or nil when the spell cannot be cast or we die.
def play(state, spell, cost, hard)
  s = state.dup
  s.hp -= 1 if hard
  return nil if s.hp <= 0

  tick(s)
  return :won if s.boss <= 0
  return nil if cost > s.mana
  return nil if s.members.include?(spell) && s[spell].positive? # an effect still running

  s.mana -= cost
  case spell
  when :missile then s.boss -= 4
  when :drain then s.boss -= 2; s.hp += 2
  when :shield then s.shield = 6
  when :poison then s.poison = 6
  when :recharge then s.recharge = 5
  end
  return :won if s.boss <= 0

  armor = tick(s)
  return :won if s.boss <= 0

  s.hp -= [BOSS_DAMAGE - armor, 1].max
  s.hp.positive? ? s : nil
end

# The least mana that wins: Dijkstra, with a queue bucketed by mana spent.
def least_mana(hard)
  queue = Hash.new { |h, k| h[k] = [] }
  queue[0] << State.new(50, 500, BOSS_HP, 0, 0, 0)
  seen = {}
  spent = 0
  loop do
    queue.delete(spent)&.each do |state|
      next if seen[state.to_a]

      seen[state.to_a] = true
      SPELLS.each do |spell, cost|
        result = play(state, spell, cost, hard)
        return spent + cost if result == :won
        queue[spent + cost] << result if result
      end
    end
    spent += 1
  end
end

puts least_mana(false)
puts least_mana(true)
