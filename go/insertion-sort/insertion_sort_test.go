package main

import (
	"math/rand"
	"reflect"
	stdsort "sort"
	"testing"
)

func TestSort(t *testing.T) {
	cases := []struct {
		name  string
		input []int
		want  []int
	}{
		{"empty", []int{}, []int{}},
		{"single", []int{1}, []int{1}},
		{"already sorted", []int{1, 2, 3, 4}, []int{1, 2, 3, 4}},
		{"reversed", []int{4, 3, 2, 1}, []int{1, 2, 3, 4}},
		{"duplicates", []int{2, 5, 1, 2, 3, 4, 7, 6}, []int{1, 2, 2, 3, 4, 5, 6, 7}},
		{"negatives", []int{0, -3, 5, -1}, []int{-3, -1, 0, 5}},
		{"program input", []int{1, 5, 3, 4, 6, 7, 8}, []int{1, 3, 4, 5, 6, 7, 8}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := append([]int{}, tc.input...)
			sort(got)
			if !reflect.DeepEqual(got, tc.want) {
				t.Errorf("sort(%v) = %v, want %v", tc.input, got, tc.want)
			}
		})
	}
}

func TestSortMatchesStandardLibrary(t *testing.T) {
	r := rand.New(rand.NewSource(1))
	for i := 0; i < 500; i++ {
		input := make([]int, r.Intn(30))
		for j := range input {
			input[j] = r.Intn(100) - 50
		}
		got := append([]int{}, input...)
		want := append([]int{}, input...)
		sort(got)
		stdsort.Ints(want)
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("sort(%v) = %v, want %v", input, got, want)
		}
	}
}
