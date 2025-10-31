// Day 13: Claw Contraption
package main

import (
	"aoc2024/aoc"
	"strings"
)

// tokens solves a*A + b*B = prize exactly (Cramer's rule); 0 if impossible.
func tokens(ax, ay, bx, by, px, py int) int {
	det := ax*by - ay*bx
	if det == 0 {
		return 0
	}
	a := px*by - py*bx
	b := ax*py - ay*px
	if a%det != 0 || b%det != 0 || a/det < 0 || b/det < 0 {
		return 0
	}
	return 3*(a/det) + b/det
}

func main() {
	part1, part2 := 0, 0
	for _, machine := range strings.Split(strings.TrimSpace(aoc.Input()), "\n\n") {
		n := aoc.Ints(machine)
		part1 += tokens(n[0], n[1], n[2], n[3], n[4], n[5])
		const far = 10000000000000
		part2 += tokens(n[0], n[1], n[2], n[3], n[4]+far, n[5]+far)
	}
	aoc.Answer(part1, part2)
}
