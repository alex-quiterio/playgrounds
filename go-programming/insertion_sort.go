package main
import (
	"fmt"
)

/*
 * Insertion Sort Algorithm
 */
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
	fmt.Println(array)
}

func main() {
	sort([]int{1, 5, 3, 4, 6, 7, 8})
	sort([]int{2, 5, 1, 2, 3, 4, 7, 6})
}
