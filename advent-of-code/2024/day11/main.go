// Day 11: Plutonian Pebbles
package main

import (
	"aoc2024/aoc"
	"strconv"
)

type key struct{ stone, blinks int }

// count returns how many stones one stone becomes after some blinks.
func count(stone, blinks int, memo map[key]int) int {
	if blinks == 0 {
		return 1
	}
	k := key{stone, blinks}
	if n, ok := memo[k]; ok {
		return n
	}
	var n int
	digits := strconv.Itoa(stone)
	switch {
	case stone == 0:
		n = count(1, blinks-1, memo)
	case len(digits)%2 == 0:
		left, _ := strconv.Atoi(digits[:len(digits)/2])
		right, _ := strconv.Atoi(digits[len(digits)/2:])
		n = count(left, blinks-1, memo) + count(right, blinks-1, memo)
	default:
		n = count(stone*2024, blinks-1, memo)
	}
	memo[k] = n
	return n
}

func main() {
	memo := map[key]int{}
	part1, part2 := 0, 0
	for _, stone := range aoc.Ints(aoc.Input()) {
		part1 += count(stone, 25, memo)
		part2 += count(stone, 75, memo)
	}
	aoc.Answer(part1, part2)
}
