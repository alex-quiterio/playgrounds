// Day 15: Warehouse Woes
package main

import (
	"aoc2024/aoc"
	"strings"
)

var moves = map[rune]aoc.Point{'^': {R: -1}, 'v': {R: 1}, '<': {C: -1}, '>': {C: 1}}

// simulate runs the robot on the warehouse and returns the GPS sum of the boxes.
func simulate(rows []string, path string) int {
	grid := make([][]byte, len(rows))
	var robot aoc.Point
	for r, row := range rows {
		grid[r] = []byte(row)
		if c := strings.IndexByte(row, '@'); c >= 0 {
			robot = aoc.Point{R: r, C: c}
		}
	}
	at := func(p aoc.Point) byte { return grid[p.R][p.C] }

	for _, m := range path {
		d, ok := moves[m]
		if !ok {
			continue
		}
		// Collect every cell that would move, breadth first.
		toMove := []aoc.Point{robot}
		seen := map[aoc.Point]bool{robot: true}
		blocked := false
		for i := 0; i < len(toMove) && !blocked; i++ {
			next := toMove[i].Add(d)
			switch at(next) {
			case '#':
				blocked = true
			case 'O':
				add(&toMove, seen, next)
			case '[':
				add(&toMove, seen, next)
				add(&toMove, seen, next.Add(aoc.Point{C: 1}))
			case ']':
				add(&toMove, seen, next)
				add(&toMove, seen, next.Add(aoc.Point{C: -1}))
			}
		}
		if blocked {
			continue
		}
		for i := len(toMove) - 1; i >= 0; i-- {
			p, q := toMove[i], toMove[i].Add(d)
			grid[q.R][q.C], grid[p.R][p.C] = grid[p.R][p.C], '.'
		}
		robot = robot.Add(d)
	}

	sum := 0
	for r, row := range grid {
		for c, ch := range row {
			if ch == 'O' || ch == '[' {
				sum += 100*r + c
			}
		}
	}
	return sum
}

func add(list *[]aoc.Point, seen map[aoc.Point]bool, p aoc.Point) {
	if !seen[p] {
		seen[p] = true
		*list = append(*list, p)
	}
}

func main() {
	parts := strings.SplitN(strings.ReplaceAll(aoc.Input(), "\r\n", "\n"), "\n\n", 2)
	rows, path := aoc.Lines(parts[0]), parts[1]

	wide := make([]string, len(rows))
	widen := strings.NewReplacer("#", "##", "O", "[]", ".", "..", "@", "@.")
	for i, row := range rows {
		wide[i] = widen.Replace(row)
	}
	aoc.Answer(simulate(rows, path), simulate(wide, path))
}
