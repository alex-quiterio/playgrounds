// Day 19: Linen Layout
package main

import (
	"aoc2024/aoc"
	"strings"
)

// ways counts how many ways towels can make the design.
func ways(design string, towels []string) int {
	counts := make([]int, len(design)+1)
	counts[0] = 1
	for i := 0; i < len(design); i++ {
		if counts[i] == 0 {
			continue
		}
		for _, t := range towels {
			if strings.HasPrefix(design[i:], t) {
				counts[i+len(t)] += counts[i]
			}
		}
	}
	return counts[len(design)]
}

func main() {
	lines := aoc.Lines(aoc.Input())
	towels := strings.Split(lines[0], ", ")
	possible, total := 0, 0
	for _, design := range lines[1:] {
		n := ways(design, towels)
		if n > 0 {
			possible++
		}
		total += n
	}
	aoc.Answer(possible, total)
}
