// Day 6: Guard Gallivant
package main

import "aoc2024/aoc"

var directions = []aoc.Point{{R: -1}, {C: 1}, {R: 1}, {C: -1}} // up, right, down, left

type state struct {
	p   aoc.Point
	dir int
}

// walk follows the guard until she leaves the map. It returns the visited
// cells, or loops=true if she walks in circles.
func walk(grid aoc.Grid, start aoc.Point, obstacle aoc.Point) (visited map[aoc.Point]bool, loops bool) {
	visited = map[aoc.Point]bool{}
	seen := map[state]bool{}
	s := state{start, 0}
	for grid.In(s.p) {
		if seen[s] {
			return visited, true
		}
		seen[s] = true
		visited[s.p] = true
		next := s.p.Add(directions[s.dir])
		if grid.At(next) == '#' || next == obstacle {
			s.dir = (s.dir + 1) % 4
		} else {
			s.p = next
		}
	}
	return visited, false
}

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	var start aoc.Point
	for r := range grid {
		for c := range grid[r] {
			if grid[r][c] == '^' {
				start = aoc.Point{R: r, C: c}
			}
		}
	}
	none := aoc.Point{R: -1, C: -1}
	path, _ := walk(grid, start, none)

	loops := 0
	for p := range path { // an obstacle off her path changes nothing
		if p == start {
			continue
		}
		if _, loop := walk(grid, start, p); loop {
			loops++
		}
	}
	aoc.Answer(len(path), loops)
}
