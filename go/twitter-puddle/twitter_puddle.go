package main

import (
	"fmt"
)

type Puddle struct {
	X    int
	XPos int
	Y    int
	YPos int
}

func (p *Puddle) inspect() {
	fmt.Printf("X: %d, XPos: %d, Y:%d, YPos:%d\n", p.X, p.XPos, p.Y, p.YPos)
}

// waterLevels returns, for every position, the height the water would reach
// there: the lower of the tallest wall on its left and on its right.
func waterLevels(montain []int) []int {
	n := len(montain)
	levels := make([]int, n)
	if n == 0 {
		return levels
	}
	leftMax := make([]int, n)
	leftMax[0] = montain[0]
	for i := 1; i < n; i++ {
		leftMax[i] = max(leftMax[i-1], montain[i])
	}
	rightMax := montain[n-1]
	for i := n - 1; i >= 0; i-- {
		rightMax = max(rightMax, montain[i])
		levels[i] = min(leftMax[i], rightMax)
	}
	return levels
}

// findPuddles returns every puddle in the montain: a run of positions under
// water, bounded by the dry walls at XPos and YPos.
func findPuddles(montain []int) []Puddle {
	levels := waterLevels(montain)
	puddles := []Puddle{}
	for i := 1; i < len(montain)-1; i++ {
		if levels[i] <= montain[i] {
			continue
		}
		left := i - 1
		for levels[i] > montain[i] {
			i++
		}
		// Inside a puddle the level is constant and equals the lower wall.
		puddles = append(puddles, Puddle{montain[left], left, montain[i], i})
	}
	return puddles
}

// waterRetained returns how many units of water the montain profile holds.
func waterRetained(montain []int) int {
	puddles := findPuddles(montain)
	water := 0
	for _, puddle := range puddles {
		for i := puddle.XPos + 1; i < puddle.YPos; i++ {
			if puddle.X <= puddle.Y {
				water += puddle.X - montain[i]
			}
			if puddle.X > puddle.Y {
				water += puddle.Y - montain[i]
			}
		}
	}
	return water
}

func twitterPuddle(montain []int, expectedValue int) {
	water := waterRetained(montain)
	if expectedValue != water {
		fmt.Printf("[L] Expected Value: %d, Water retained: %d\n", expectedValue, water)
	} else {
		fmt.Printf("[W] Total Retained Water Value: %d!\n", water)
	}
}

func main() {
	twitterPuddle([]int{2, 5, 1, 2, 3, 4, 7, 7, 6}, 10)
	twitterPuddle([]int{2, 5, 1, 2, 3, 4, 7, 7, 6, 5, 4, 4, 4, 2, 3}, 11)
	twitterPuddle([]int{2, 5, 1, 3, 1, 2, 1, 7, 7, 6}, 17)
	twitterPuddle([]int{2, 7, 2, 7, 4, 7, 1, 7, 3, 7}, 18)
	twitterPuddle([]int{7, 7, 7, 2, 7, 7, 7, 7, 7, 7, 7}, 5)
	twitterPuddle([]int{6, 7, 7, 4, 3, 2, 1, 5, 2}, 10)
	twitterPuddle([]int{2, 5, 1, 2, 3, 4, 7, 6, 2, 7, 1, 2, 3, 4, 5, 4}, 26)
}
