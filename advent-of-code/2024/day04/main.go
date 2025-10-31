// Day 4: Ceres Search
package main

import "aoc2024/aoc"

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	xmas, crosses := 0, 0
	for r := range grid {
		for c := range grid[r] {
			p := aoc.Point{R: r, C: c}
			for dr := -1; dr <= 1; dr++ {
				for dc := -1; dc <= 1; dc++ {
					if (dr != 0 || dc != 0) && spells(grid, p, aoc.Point{R: dr, C: dc}, "XMAS") {
						xmas++
					}
				}
			}
			if grid.At(p) == 'A' && diagonalMAS(grid, p, 1) && diagonalMAS(grid, p, -1) {
				crosses++
			}
		}
	}
	aoc.Answer(xmas, crosses)
}

func spells(grid aoc.Grid, p, d aoc.Point, word string) bool {
	for i := 0; i < len(word); i++ {
		if grid.At(p) != word[i] {
			return false
		}
		p = p.Add(d)
	}
	return true
}

// diagonalMAS reports whether the diagonal through the A at p reads MAS either way.
func diagonalMAS(grid aoc.Grid, p aoc.Point, slope int) bool {
	a := grid.At(aoc.Point{R: p.R - 1, C: p.C - slope})
	b := grid.At(aoc.Point{R: p.R + 1, C: p.C + slope})
	return (a == 'M' && b == 'S') || (a == 'S' && b == 'M')
}
