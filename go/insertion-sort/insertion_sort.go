package main

import (
	"fmt"
)

// sort orders array in place, ascending, using insertion sort.
func sort(array []int) {
	var key int
	var j int
	for i := 1; i < len(array); i++ {
		key = array[i]
		j = i
		for j > 0 && array[j-1] > key {
			array[j] = array[j-1]
			j = j - 1
		}
		array[j] = key
	}
}

func main() {
	for _, array := range [][]int{
		{1, 5, 3, 4, 6, 7, 8},
		{2, 5, 1, 2, 3, 4, 7, 6},
	} {
		sort(array)
		fmt.Println(array)
	}
}
