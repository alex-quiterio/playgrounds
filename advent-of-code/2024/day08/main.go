// Day 8: Resonant Collinearity
package main

import "aoc2024/aoc"

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	antennas := map[byte][]aoc.Point{}
	for r := range grid {
		for c := range grid[r] {
			if grid[r][c] != '.' {
				antennas[grid[r][c]] = append(antennas[grid[r][c]], aoc.Point{R: r, C: c})
			}
		}
	}

	antinodes, harmonics := map[aoc.Point]bool{}, map[aoc.Point]bool{}
	for _, group := range antennas {
		for _, a := range group {
			for _, b := range group {
				if a == b {
					continue
				}
				step := aoc.Point{R: b.R - a.R, C: b.C - a.C}
				if p := b.Add(step); grid.In(p) {
					antinodes[p] = true
				}
				for p := b; grid.In(p); p = p.Add(step) {
					harmonics[p] = true
				}
			}
		}
	}
	aoc.Answer(len(antinodes), len(harmonics))
}
