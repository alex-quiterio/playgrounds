// Day 24: Crossed Wires
package main

import (
	"aoc2024/aoc"
	"sort"
	"strings"
)

type gate struct{ a, op, b, out string }

func main() {
	parts := strings.SplitN(strings.ReplaceAll(aoc.Input(), "\r\n", "\n"), "\n\n", 2)
	values := map[string]int{}
	for _, line := range aoc.Lines(parts[0]) {
		name, v, _ := strings.Cut(line, ": ")
		values[name] = int(v[0] - '0')
	}
	var gates []gate
	for _, line := range aoc.Lines(parts[1]) {
		f := strings.Fields(line)
		gates = append(gates, gate{f[0], f[1], f[2], f[4]})
	}

	// Part 1: evaluate until every gate has fired.
	for done := false; !done; {
		done = true
		for _, g := range gates {
			if _, ok := values[g.out]; ok {
				continue
			}
			a, okA := values[g.a]
			b, okB := values[g.b]
			if !okA || !okB {
				done = false
				continue
			}
			switch g.op {
			case "AND":
				values[g.out] = a & b
			case "OR":
				values[g.out] = a | b
			case "XOR":
				values[g.out] = a ^ b
			}
		}
	}
	number := 0
	for name, v := range values {
		if name[0] == 'z' && v == 1 {
			bit := aoc.Ints(name)[0]
			number |= 1 << bit
		}
	}

	// Part 2: the circuit should be a ripple-carry adder. Flag every gate
	// whose output breaks the adder's wiring rules.
	lastZ := ""
	for _, g := range gates {
		if g.out[0] == 'z' && g.out > lastZ {
			lastZ = g.out
		}
	}
	feeds := func(out, op string) bool {
		for _, g := range gates {
			if (g.a == out || g.b == out) && g.op == op {
				return true
			}
		}
		return false
	}
	isInput := func(w string) bool { return w[0] == 'x' || w[0] == 'y' }
	wrong := map[string]bool{}
	for _, g := range gates {
		firstBit := (g.a == "x00" || g.b == "x00")
		switch {
		case g.out[0] == 'z' && g.op != "XOR" && g.out != lastZ:
			wrong[g.out] = true // sum bits come from XOR
		case g.op == "XOR" && g.out[0] != 'z' && !isInput(g.a) && !isInput(g.b):
			wrong[g.out] = true // an inner XOR must output a sum bit
		case g.op == "XOR" && isInput(g.a) && !firstBit && !feeds(g.out, "XOR"):
			wrong[g.out] = true // x XOR y feeds the sum XOR
		case g.op == "AND" && !firstBit && !feeds(g.out, "OR"):
			wrong[g.out] = true // carries go through OR
		}
	}
	var names []string
	for w := range wrong {
		names = append(names, w)
	}
	sort.Strings(names)
	aoc.Answer(number, strings.Join(names, ","))
}
