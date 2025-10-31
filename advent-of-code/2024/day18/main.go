// Day 18: RAM Run
package main

import (
	"aoc2024/aoc"
	"fmt"
)

// shortest returns the fewest steps from the top left to the bottom right
// with the first `fallen` bytes in place, or -1 if there is no way through.
func shortest(bytes []aoc.Point, fallen, size int) int {
	wall := map[aoc.Point]bool{}
	for _, b := range bytes[:fallen] {
		wall[b] = true
	}
	start, goal := aoc.Point{}, aoc.Point{R: size - 1, C: size - 1}
	dist := map[aoc.Point]int{start: 0}
	queue := []aoc.Point{start}
	for len(queue) > 0 {
		p := queue[0]
		queue = queue[1:]
		if p == goal {
			return dist[p]
		}
		for _, d := range []aoc.Point{{R: 1}, {R: -1}, {C: 1}, {C: -1}} {
			q := p.Add(d)
			if q.R < 0 || q.C < 0 || q.R >= size || q.C >= size || wall[q] {
				continue
			}
			if _, ok := dist[q]; !ok {
				dist[q] = dist[p] + 1
				queue = append(queue, q)
			}
		}
	}
	return -1
}

func main() {
	var bytes []aoc.Point
	for _, line := range aoc.Lines(aoc.Input()) {
		n := aoc.Ints(line)
		bytes = append(bytes, aoc.Point{R: n[1], C: n[0]})
	}
	// The example is a 7x7 grid after 12 bytes; the real one is 71x71 after 1024.
	size, fallen := 71, 1024
	if len(bytes) < 100 {
		size, fallen = 7, 12
	}
	// Binary search for the first byte that cuts the path.
	low, high := fallen, len(bytes)
	for low < high {
		mid := (low + high) / 2
		if shortest(bytes, mid, size) < 0 {
			high = mid
		} else {
			low = mid + 1
		}
	}
	cut := bytes[low-1]
	aoc.Answer(shortest(bytes, fallen, size), fmt.Sprintf("%d,%d", cut.C, cut.R))
}
