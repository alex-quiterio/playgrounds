// Day 3: Mull It Over
package main

import (
	"aoc2024/aoc"
	"regexp"
	"strconv"
)

var instruction = regexp.MustCompile(`mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)`)

func main() {
	part1, part2 := 0, 0
	enabled := true
	for _, m := range instruction.FindAllStringSubmatch(aoc.Input(), -1) {
		switch m[0] {
		case "do()":
			enabled = true
		case "don't()":
			enabled = false
		default:
			a, _ := strconv.Atoi(m[1])
			b, _ := strconv.Atoi(m[2])
			part1 += a * b
			if enabled {
				part2 += a * b
			}
		}
	}
	aoc.Answer(part1, part2)
}
