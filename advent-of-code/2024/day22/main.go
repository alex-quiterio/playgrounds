// Day 22: Monkey Market
package main

import "aoc2024/aoc"

func next(n int) int {
	n = (n ^ (n << 6)) & 0xFFFFFF
	n = (n ^ (n >> 5)) & 0xFFFFFF
	return (n ^ (n << 11)) & 0xFFFFFF
}

func main() {
	sum := 0
	bananas := map[[4]int]int{} // total bananas per sequence of four price changes
	for _, secret := range aoc.Ints(aoc.Input()) {
		seen := map[[4]int]bool{}
		var changes [4]int
		price := secret % 10
		for i := 1; i <= 2000; i++ {
			secret = next(secret)
			p := secret % 10
			changes = [4]int{changes[1], changes[2], changes[3], p - price}
			price = p
			if i >= 4 && !seen[changes] {
				seen[changes] = true // the monkey sells the first time it sees it
				bananas[changes] += p
			}
		}
		sum += secret
	}
	best := 0
	for _, b := range bananas {
		best = max(best, b)
	}
	aoc.Answer(sum, best)
}
