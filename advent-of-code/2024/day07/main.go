// Day 7: Bridge Repair
package main

import (
	"aoc2024/aoc"
	"strconv"
)

// solvable reports whether the numbers, combined left to right, can make target.
func solvable(target, value int, rest []int, concat bool) bool {
	if len(rest) == 0 {
		return value == target
	}
	if value > target {
		return false
	}
	next := rest[0]
	if solvable(target, value+next, rest[1:], concat) || solvable(target, value*next, rest[1:], concat) {
		return true
	}
	if concat {
		joined, _ := strconv.Atoi(strconv.Itoa(value) + strconv.Itoa(next))
		return solvable(target, joined, rest[1:], concat)
	}
	return false
}

func main() {
	part1, part2 := 0, 0
	for _, line := range aoc.Lines(aoc.Input()) {
		n := aoc.Ints(line)
		target, numbers := n[0], n[1:]
		if solvable(target, numbers[0], numbers[1:], false) {
			part1 += target
		}
		if solvable(target, numbers[0], numbers[1:], true) {
			part2 += target
		}
	}
	aoc.Answer(part1, part2)
}
