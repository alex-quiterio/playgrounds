// Day 20: Race Condition
package main

import "aoc2024/aoc"

// cheats counts the shortcuts of at most `length` picoseconds through walls
// that save at least `saving` picoseconds.
func cheats(path []aoc.Point, length, saving int) int {
	count := 0
	for i := range path {
		for j := i + saving; j < len(path); j++ {
			d := abs(path[i].R-path[j].R) + abs(path[i].C-path[j].C)
			if d <= length && j-i-d >= saving {
				count++
			}
		}
	}
	return count
}

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	var start aoc.Point
	for r := range grid {
		for c := range grid[r] {
			if grid[r][c] == 'S' {
				start = aoc.Point{R: r, C: c}
			}
		}
	}
	// The track is a single path: walk it in order.
	path := []aoc.Point{start}
	prev := aoc.Point{R: -1, C: -1}
	for grid.At(path[len(path)-1]) != 'E' {
		p := path[len(path)-1]
		for _, d := range []aoc.Point{{R: 1}, {R: -1}, {C: 1}, {C: -1}} {
			q := p.Add(d)
			if q != prev && grid.At(q) != '#' {
				prev = p
				path = append(path, q)
				break
			}
		}
	}
	// The example lists every saving; the real input asks for at least 100.
	saving1, saving2 := 100, 100
	if len(grid) < 20 {
		saving1, saving2 = 1, 50
	}
	aoc.Answer(cheats(path, 2, saving1), cheats(path, 20, saving2))
}
