// Day 14: Restroom Redoubt
package main

import "aoc2024/aoc"

type robot struct{ px, py, vx, vy int }

func mod(a, m int) int { return ((a % m) + m) % m }

func main() {
	var robots []robot
	for _, line := range aoc.Lines(aoc.Input()) {
		n := aoc.Ints(line)
		robots = append(robots, robot{n[0], n[1], n[2], n[3]})
	}
	// The example room is 11 x 7; the real one is 101 x 103.
	width, height := 101, 103
	if len(robots) < 20 {
		width, height = 11, 7
	}

	quadrants := [4]int{}
	for _, r := range robots {
		x, y := mod(r.px+100*r.vx, width), mod(r.py+100*r.vy, height)
		if x == width/2 || y == height/2 {
			continue
		}
		q := 0
		if x > width/2 {
			q++
		}
		if y > height/2 {
			q += 2
		}
		quadrants[q]++
	}
	safety := quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3]

	// The tree appears the first second no two robots overlap.
	tree := 0
	for t := 1; t <= width*height; t++ {
		taken := map[[2]int]bool{}
		overlap := false
		for _, r := range robots {
			p := [2]int{mod(r.px+t*r.vx, width), mod(r.py+t*r.vy, height)}
			if taken[p] {
				overlap = true
				break
			}
			taken[p] = true
		}
		if !overlap {
			tree = t
			break
		}
	}
	aoc.Answer(safety, tree)
}
