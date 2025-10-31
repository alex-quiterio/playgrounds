// Day 12: Garden Groups
package main

import "aoc2024/aoc"

var dirs = []aoc.Point{{R: -1}, {C: 1}, {R: 1}, {C: -1}}

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	seen := map[aoc.Point]bool{}
	part1, part2 := 0, 0
	for r := range grid {
		for c := range grid[r] {
			start := aoc.Point{R: r, C: c}
			if seen[start] {
				continue
			}
			plant := grid.At(start)
			area, perimeter, corners := 0, 0, 0
			stack := []aoc.Point{start}
			seen[start] = true
			same := func(p aoc.Point) bool { return grid.At(p) == plant }
			for len(stack) > 0 {
				p := stack[len(stack)-1]
				stack = stack[:len(stack)-1]
				area++
				for i, d := range dirs {
					q := p.Add(d)
					if !same(q) {
						perimeter++
					} else if !seen[q] {
						seen[q] = true
						stack = append(stack, q)
					}
					// A region has as many sides as corners.
					e := dirs[(i+1)%4]
					diagonal := p.Add(d).Add(e)
					if !same(p.Add(d)) && !same(p.Add(e)) {
						corners++ // outer corner
					} else if same(p.Add(d)) && same(p.Add(e)) && !same(diagonal) {
						corners++ // inner corner
					}
				}
			}
			part1 += area * perimeter
			part2 += area * corners
		}
	}
	aoc.Answer(part1, part2)
}
