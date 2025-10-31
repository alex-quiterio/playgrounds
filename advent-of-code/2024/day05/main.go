// Day 5: Print Queue
package main

import (
	"aoc2024/aoc"
	"sort"
	"strings"
)

func main() {
	before := map[[2]int]bool{} // before[{a, b}]: a must be printed before b
	var updates [][]int
	for _, line := range aoc.Lines(aoc.Input()) {
		n := aoc.Ints(line)
		if strings.Contains(line, "|") {
			before[[2]int{n[0], n[1]}] = true
		} else {
			updates = append(updates, n)
		}
	}

	part1, part2 := 0, 0
	for _, update := range updates {
		ordered := append([]int{}, update...)
		sort.SliceStable(ordered, func(i, j int) bool { return before[[2]int{ordered[i], ordered[j]}] })
		middle := ordered[len(ordered)/2]
		if equal(ordered, update) {
			part1 += middle
		} else {
			part2 += middle
		}
	}
	aoc.Answer(part1, part2)
}

func equal(a, b []int) bool {
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}
