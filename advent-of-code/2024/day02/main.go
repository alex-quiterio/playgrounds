// Day 2: Red-Nosed Reports
package main

import "aoc2024/aoc"

// safe reports whether levels all increase or all decrease by 1 to 3.
func safe(levels []int) bool {
	increasing := levels[1] > levels[0]
	for i := 1; i < len(levels); i++ {
		step := levels[i] - levels[i-1]
		if !increasing {
			step = -step
		}
		if step < 1 || step > 3 {
			return false
		}
	}
	return true
}

// safeWithDampener reports whether removing at most one level makes the report safe.
func safeWithDampener(levels []int) bool {
	for skip := range levels {
		rest := append(append([]int{}, levels[:skip]...), levels[skip+1:]...)
		if safe(rest) {
			return true
		}
	}
	return false
}

func main() {
	part1, part2 := 0, 0
	for _, line := range aoc.Lines(aoc.Input()) {
		levels := aoc.Ints(line)
		if safe(levels) {
			part1++
		}
		if safeWithDampener(levels) {
			part2++
		}
	}
	aoc.Answer(part1, part2)
}
