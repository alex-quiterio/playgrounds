# Day 11: Corporate Policy

# A valid password has a straight of three letters (abc, xyz), none of i, o
# or l, and two different pairs of repeated letters.
def valid?(password)
  password.each_char.each_cons(3).any? { |a, b, c| b == a.next && c == b.next } &&
    !password.match?(/[iol]/) &&
    password.scan(/(.)\1/).uniq.size >= 2
end

# String#succ already counts like the puzzle does (az -> ba, zz -> aaa).
# Skipping straight past a forbidden letter saves trying the whole range after it.
def next_password(password)
  loop do
    password = password.succ
    if (i = password.index(/[iol]/))
      password = password[0...i] + password[i].next + 'a' * (password.length - i - 1)
    end
    return password if valid?(password)
  end
end

first = next_password(File.read(ARGV.fetch(0)).strip)
puts first
puts next_password(first)
