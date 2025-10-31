// Day 1: Historian Hysteria
package main

import (
	"aoc2024/aoc"
	"sort"
)

func main() {
	var left, right []int
	for _, line := range aoc.Lines(aoc.Input()) {
		n := aoc.Ints(line)
		left, right = append(left, n[0]), append(right, n[1])
	}
	sort.Ints(left)
	sort.Ints(right)

	distance := 0
	for i := range left {
		distance += abs(left[i] - right[i])
	}

	counts := map[int]int{}
	for _, n := range right {
		counts[n]++
	}
	similarity := 0
	for _, n := range left {
		similarity += n * counts[n]
	}
	aoc.Answer(distance, similarity)
}

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}
