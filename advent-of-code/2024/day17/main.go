// Day 17: Chronospatial Computer
package main

import (
	"aoc2024/aoc"
	"strconv"
	"strings"
)

func run(a, b, c int, program []int) []int {
	var out []int
	combo := func(op int) int {
		switch op {
		case 4:
			return a
		case 5:
			return b
		case 6:
			return c
		}
		return op
	}
	for ip := 0; ip+1 < len(program); ip += 2 {
		op := program[ip+1]
		switch program[ip] {
		case 0:
			a >>= combo(op)
		case 1:
			b ^= op
		case 2:
			b = combo(op) % 8
		case 3:
			if a != 0 {
				ip = op - 2
			}
		case 4:
			b ^= c
		case 5:
			out = append(out, combo(op)%8)
		case 6:
			b = a >> combo(op)
		case 7:
			c = a >> combo(op)
		}
	}
	return out
}

func join(values []int) string {
	parts := make([]string, len(values))
	for i, v := range values {
		parts[i] = strconv.Itoa(v)
	}
	return strings.Join(parts, ",")
}

// quine finds the lowest A that makes the program print itself. The program
// consumes A three bits per output, so build A from the last output back.
func quine(program []int, a, i int) (int, bool) {
	if i < 0 {
		return a, true
	}
	for bits := 0; bits < 8; bits++ {
		candidate := a<<3 | bits
		out := run(candidate, 0, 0, program)
		if len(out) > 0 && join(out) == join(program[i:]) {
			if found, ok := quine(program, candidate, i-1); ok {
				return found, true
			}
		}
	}
	return 0, false
}

func main() {
	n := aoc.Ints(aoc.Input())
	program := n[3:]
	a, ok := quine(program, 0, len(program)-1)
	if !ok {
		aoc.Answer(join(run(n[0], n[1], n[2], program)), "none")
		return
	}
	aoc.Answer(join(run(n[0], n[1], n[2], program)), a)
}
