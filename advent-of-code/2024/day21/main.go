// Day 21: Keypad Conundrum
package main

import (
	"aoc2024/aoc"
	"strconv"
	"strings"
)

var numeric = map[byte]aoc.Point{
	'7': {R: 0, C: 0}, '8': {R: 0, C: 1}, '9': {R: 0, C: 2},
	'4': {R: 1, C: 0}, '5': {R: 1, C: 1}, '6': {R: 1, C: 2},
	'1': {R: 2, C: 0}, '2': {R: 2, C: 1}, '3': {R: 2, C: 2},
	'0': {R: 3, C: 1}, 'A': {R: 3, C: 2},
}
var numericGap = aoc.Point{R: 3, C: 0}

var directional = map[byte]aoc.Point{
	'^': {R: 0, C: 1}, 'A': {R: 0, C: 2},
	'<': {R: 1, C: 0}, 'v': {R: 1, C: 1}, '>': {R: 1, C: 2},
}
var directionalGap = aoc.Point{R: 0, C: 0}

// moves returns the candidate key sequences (ending in A) from one key to another.
func moves(from, to, gap aoc.Point) []string {
	vertical, horizontal := "", ""
	for r := from.R; r < to.R; r++ {
		vertical += "v"
	}
	for r := from.R; r > to.R; r-- {
		vertical += "^"
	}
	for c := from.C; c < to.C; c++ {
		horizontal += ">"
	}
	for c := from.C; c > to.C; c-- {
		horizontal += "<"
	}
	var options []string
	// Horizontal first, unless that passes over the gap.
	if !(from.R == gap.R && to.C == gap.C) {
		options = append(options, horizontal+vertical+"A")
	}
	if !(from.C == gap.C && to.R == gap.R) {
		options = append(options, vertical+horizontal+"A")
	}
	return options
}

type key struct {
	seq   string
	depth int
}

// cost is the number of human presses to type seq on a directional keypad
// operated through `depth` more robots.
func cost(seq string, depth int, memo map[key]int) int {
	if depth == 0 {
		return len(seq)
	}
	k := key{seq, depth}
	if n, ok := memo[k]; ok {
		return n
	}
	total := 0
	at := directional['A']
	for i := 0; i < len(seq); i++ {
		next := directional[seq[i]]
		best := -1
		for _, option := range moves(at, next, directionalGap) {
			if c := cost(option, depth-1, memo); best < 0 || c < best {
				best = c
			}
		}
		total += best
		at = next
	}
	memo[k] = total
	return total
}

func complexity(code string, robots int, memo map[key]int) int {
	total := 0
	at := numeric['A']
	for i := 0; i < len(code); i++ {
		next := numeric[code[i]]
		best := -1
		for _, option := range moves(at, next, numericGap) {
			if c := cost(option, robots, memo); best < 0 || c < best {
				best = c
			}
		}
		total += best
		at = next
	}
	n, _ := strconv.Atoi(strings.TrimSuffix(code, "A"))
	return total * n
}

func main() {
	memo := map[key]int{}
	part1, part2 := 0, 0
	for _, code := range aoc.Lines(aoc.Input()) {
		part1 += complexity(code, 2, memo)
		part2 += complexity(code, 25, memo)
	}
	aoc.Answer(part1, part2)
}
