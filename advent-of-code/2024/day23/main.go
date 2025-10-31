// Day 23: LAN Party
package main

import (
	"aoc2024/aoc"
	"sort"
	"strings"
)

func main() {
	links := map[string]map[string]bool{}
	connect := func(a, b string) {
		if links[a] == nil {
			links[a] = map[string]bool{}
		}
		links[a][b] = true
	}
	for _, line := range aoc.Lines(aoc.Input()) {
		a, b, _ := strings.Cut(line, "-")
		connect(a, b)
		connect(b, a)
	}
	var names []string
	for n := range links {
		names = append(names, n)
	}
	sort.Strings(names)

	// Triangles with at least one computer starting with t.
	triangles := 0
	for i, a := range names {
		for j := i + 1; j < len(names); j++ {
			b := names[j]
			if !links[a][b] {
				continue
			}
			for k := j + 1; k < len(names); k++ {
				c := names[k]
				if links[a][c] && links[b][c] && (a[0] == 't' || b[0] == 't' || c[0] == 't') {
					triangles++
				}
			}
		}
	}

	// Largest clique (Bron-Kerbosch).
	var best []string
	var grow func(r []string, p, x map[string]bool)
	grow = func(r []string, p, x map[string]bool) {
		if len(p) == 0 && len(x) == 0 {
			if len(r) > len(best) {
				best = append([]string{}, r...)
			}
			return
		}
		for v := range p {
			np, nx := map[string]bool{}, map[string]bool{}
			for u := range p {
				if links[v][u] {
					np[u] = true
				}
			}
			for u := range x {
				if links[v][u] {
					nx[u] = true
				}
			}
			grow(append(r, v), np, nx)
			delete(p, v)
			x[v] = true
		}
	}
	all := map[string]bool{}
	for _, n := range names {
		all[n] = true
	}
	grow(nil, all, map[string]bool{})
	sort.Strings(best)
	aoc.Answer(triangles, strings.Join(best, ","))
}
