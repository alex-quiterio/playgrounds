package main

import (
	"math/rand"
	"testing"
)

// trappedWater is a reference two-pointer solution used to check waterRetained.
func trappedWater(heights []int) int {
	left, right := 0, len(heights)-1
	leftMax, rightMax, water := 0, 0, 0
	for left < right {
		if heights[left] < heights[right] {
			if heights[left] >= leftMax {
				leftMax = heights[left]
			} else {
				water += leftMax - heights[left]
			}
			left++
		} else {
			if heights[right] >= rightMax {
				rightMax = heights[right]
			} else {
				water += rightMax - heights[right]
			}
			right--
		}
	}
	return water
}

func TestWaterRetainedExamples(t *testing.T) {
	cases := []struct {
		montain []int
		want    int
	}{
		{[]int{2, 5, 1, 2, 3, 4, 7, 7, 6}, 10},
		{[]int{2, 5, 1, 2, 3, 4, 7, 7, 6, 5, 4, 4, 4, 2, 3}, 11},
		{[]int{2, 5, 1, 3, 1, 2, 1, 7, 7, 6}, 17},
		{[]int{2, 7, 2, 7, 4, 7, 1, 7, 3, 7}, 18},
		{[]int{7, 7, 7, 2, 7, 7, 7, 7, 7, 7, 7}, 5},
		{[]int{6, 7, 7, 4, 3, 2, 1, 5, 2}, 10},
		{[]int{2, 5, 1, 2, 3, 4, 7, 6, 2, 7, 1, 2, 3, 4, 5, 4}, 26},
		{[]int{1, 2, 3, 4, 5}, 0},
		{[]int{5, 4, 3, 2, 1}, 0},
		{[]int{3, 3, 3}, 0},
	}
	for _, tc := range cases {
		if got := waterRetained(tc.montain); got != tc.want {
			t.Errorf("waterRetained(%v) = %d, want %d", tc.montain, got, tc.want)
		}
		if ref := trappedWater(tc.montain); ref != tc.want {
			t.Errorf("reference disagrees on %v: %d, want %d", tc.montain, ref, tc.want)
		}
	}
}

func TestWaterRetainedRegressions(t *testing.T) {
	cases := []struct {
		montain []int
		want    int
	}{
		{[]int{6, 1, 4, 8}, 7},
		{[]int{7, 5, 8, 2}, 2},
		{[]int{6, 3, 8, 3, 1, 3}, 5},
		{[]int{5, 2, 8, 6, 3, 6, 3, 3, 4, 2}, 8},
		{[]int{2, 6, 8, 1, 2, 1, 3, 8, 4, 4}, 25},
		{[]int{}, 0},
		{[]int{4}, 0},
		{[]int{4, 4}, 0},
	}
	for _, tc := range cases {
		if got := waterRetained(tc.montain); got != tc.want {
			t.Errorf("waterRetained(%v) = %d, want %d", tc.montain, got, tc.want)
		}
	}
}

func TestWaterRetainedMatchesReference(t *testing.T) {
	r := rand.New(rand.NewSource(1))
	for i := 0; i < 5000; i++ {
		montain := make([]int, r.Intn(20))
		for j := range montain {
			montain[j] = r.Intn(10)
		}
		if got, want := waterRetained(montain), trappedWater(montain); got != want {
			t.Fatalf("waterRetained(%v) = %d, want %d", montain, got, want)
		}
	}
}

func TestFindPuddles(t *testing.T) {
	montain := []int{2, 5, 1, 2, 3, 4, 7, 6, 2, 7}
	want := []Puddle{{5, 1, 7, 6}, {7, 6, 7, 9}}
	got := findPuddles(montain)
	if len(got) != len(want) {
		t.Fatalf("findPuddles(%v) = %v, want %v", montain, got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Errorf("findPuddles(%v)[%d] = %v, want %v", montain, i, got[i], want[i])
		}
	}
}
