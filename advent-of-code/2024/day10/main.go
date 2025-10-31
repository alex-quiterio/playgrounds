// Day 10: Hoof It
package main

import "aoc2024/aoc"

var steps = []aoc.Point{{R: -1}, {R: 1}, {C: -1}, {C: 1}}

// trails returns the 9s reachable from p climbing one step at a time, with
// how many distinct trails reach each one.
func trails(grid aoc.Grid, p aoc.Point) map[aoc.Point]int {
	if grid.At(p) == '9' {
		return map[aoc.Point]int{p: 1}
	}
	ends := map[aoc.Point]int{}
	for _, d := range steps {
		next := p.Add(d)
		if grid.At(next) == grid.At(p)+1 {
			for end, n := range trails(grid, next) {
				ends[end] += n
			}
		}
	}
	return ends
}

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	score, rating := 0, 0
	for r := range grid {
		for c := range grid[r] {
			if grid[r][c] == '0' {
				ends := trails(grid, aoc.Point{R: r, C: c})
				score += len(ends)
				for _, n := range ends {
					rating += n
				}
			}
		}
	}
	aoc.Answer(score, rating)
}
