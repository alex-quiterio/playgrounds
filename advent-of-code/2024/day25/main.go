// Day 25: Code Chronicle
package main

import (
	"aoc2024/aoc"
	"strings"
)

func main() {
	var locks, keys [][5]int
	for _, block := range strings.Split(strings.TrimSpace(strings.ReplaceAll(aoc.Input(), "\r\n", "\n")), "\n\n") {
		rows := aoc.Lines(block)
		var heights [5]int
		for _, row := range rows[1 : len(rows)-1] {
			for c := 0; c < 5; c++ {
				if row[c] == '#' {
					heights[c]++
				}
			}
		}
		if rows[0] == "#####" {
			locks = append(locks, heights)
		} else {
			keys = append(keys, heights)
		}
	}
	fits := 0
	for _, l := range locks {
		for _, k := range keys {
			ok := true
			for c := 0; c < 5; c++ {
				if l[c]+k[c] > 5 {
					ok = false
				}
			}
			if ok {
				fits++
			}
		}
	}
	aoc.Answer(fits)
}
