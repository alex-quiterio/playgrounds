// Day 16: Reindeer Maze
package main

import (
	"aoc2024/aoc"
	"container/heap"
)

var dirs = []aoc.Point{{C: 1}, {R: 1}, {C: -1}, {R: -1}} // east first

type state struct {
	p   aoc.Point
	dir int
}

type item struct {
	s    state
	cost int
}

type queue []item

func (q queue) Len() int           { return len(q) }
func (q queue) Less(i, j int) bool { return q[i].cost < q[j].cost }
func (q queue) Swap(i, j int)      { q[i], q[j] = q[j], q[i] }
func (q *queue) Push(x any)        { *q = append(*q, x.(item)) }
func (q *queue) Pop() any          { old := *q; x := old[len(old)-1]; *q = old[:len(old)-1]; return x }

// dijkstra returns the cheapest cost to every state from the starts.
func dijkstra(grid aoc.Grid, starts []state, reverse bool) map[state]int {
	dist := map[state]int{}
	q := &queue{}
	for _, s := range starts {
		dist[s] = 0
		heap.Push(q, item{s, 0})
	}
	for q.Len() > 0 {
		it := heap.Pop(q).(item)
		if it.cost > dist[it.s] {
			continue
		}
		step := dirs[it.s.dir]
		if reverse {
			step = aoc.Point{R: -step.R, C: -step.C}
		}
		next := []item{
			{state{it.s.p.Add(step), it.s.dir}, it.cost + 1},
			{state{it.s.p, (it.s.dir + 1) % 4}, it.cost + 1000},
			{state{it.s.p, (it.s.dir + 3) % 4}, it.cost + 1000},
		}
		for _, n := range next {
			if grid.At(n.s.p) == '#' {
				continue
			}
			if old, ok := dist[n.s]; !ok || n.cost < old {
				dist[n.s] = n.cost
				heap.Push(q, n)
			}
		}
	}
	return dist
}

func main() {
	grid := aoc.Grid(aoc.Lines(aoc.Input()))
	var start, end aoc.Point
	for r := range grid {
		for c := range grid[r] {
			switch grid[r][c] {
			case 'S':
				start = aoc.Point{R: r, C: c}
			case 'E':
				end = aoc.Point{R: r, C: c}
			}
		}
	}
	from := dijkstra(grid, []state{{start, 0}}, false)
	best := -1
	var ends []state
	for d := range dirs {
		if c, ok := from[state{end, d}]; ok && (best < 0 || c < best) {
			best = c
		}
	}
	for d := range dirs {
		if from[state{end, d}] == best {
			ends = append(ends, state{end, d})
		}
	}
	// A tile is on a best path if cost from start + cost to end equals the best.
	to := dijkstra(grid, ends, true)
	tiles := map[aoc.Point]bool{}
	for s, c := range from {
		if t, ok := to[s]; ok && c+t == best {
			tiles[s.p] = true
		}
	}
	aoc.Answer(best, len(tiles))
}
