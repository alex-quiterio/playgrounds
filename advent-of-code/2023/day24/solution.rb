# Day 24: Never Tell Me The Odds
HAIL = File.readlines(ARGV.fetch(0), chomp: true).reject(&:empty?).map { |l| l.scan(/-?\d+/).map(&:to_i) }

# Part 1: paths that cross inside the test area, in the future, ignoring Z.
low, high = HAIL.size < 10 ? [7, 27] : [200_000_000_000_000, 400_000_000_000_000]
crossings = HAIL.combination(2).count do |(x1, y1, _, vx1, vy1, _), (x2, y2, _, vx2, vy2, _)|
  det = vx1 * vy2 - vy1 * vx2
  next false if det.zero?

  t = Rational((x2 - x1) * vy2 - (y2 - y1) * vx2, det)
  u = Rational((x2 - x1) * vy1 - (y2 - y1) * vx1, det)
  x = x1 + vx1 * t
  y = y1 + vy1 * t
  t >= 0 && u >= 0 && x.between?(low, high) && y.between?(low, high)
end
puts crossings

# Part 2: the rock (P, V) hits every hailstone (p, v), so (P - p) x (V - v) = 0.
# Subtracting that for two hailstones cancels P x V and leaves 3 linear equations:
#   P x (vj - vi) + (pj - pi) x V = pj x vj - pi x vi
def cross(a, b) = [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]

def equations(i, j)
  pi, vi = HAIL[i][0, 3], HAIL[i][3, 3]
  pj, vj = HAIL[j][0, 3], HAIL[j][3, 3]
  w = vj.zip(vi).map { |a, b| a - b }
  d = pj.zip(pi).map { |a, b| a - b }
  rhs = cross(pj, vj).zip(cross(pi, vi)).map { |a, b| a - b }
  p_rows = [[0, w[2], -w[1]], [-w[2], 0, w[0]], [w[1], -w[0], 0]]
  v_rows = [[0, -d[2], d[1]], [d[2], 0, -d[0]], [-d[1], d[0], 0]]
  (0..2).map { |k| p_rows[k] + v_rows[k] + [rhs[k]] }
end

def solve(rows)
  rows = rows.map { |r| r.map { |x| Rational(x) } }
  n = 6
  n.times do |col|
    pivot = (col...rows.size).find { |r| !rows[r][col].zero? }
    rows[col], rows[pivot] = rows[pivot], rows[col]
    rows[col] = rows[col].map { |x| x / rows[col][col] }
    rows.each_index do |r|
      next if r == col || rows[r][col].zero?

      factor = rows[r][col]
      rows[r] = rows[r].zip(rows[col]).map { |a, b| a - factor * b }
    end
  end
  rows.first(n).map(&:last)
end

rock = solve(equations(0, 1) + equations(0, 2))
puts rock.first(3).sum.to_i
