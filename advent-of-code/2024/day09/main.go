// Day 9: Disk Fragmenter
package main

import (
	"aoc2024/aoc"
	"strings"
)

const free = -1

// layout expands the disk map into one entry per block: a file ID or free.
func layout(diskMap string) []int {
	var blocks []int
	for i, ch := range diskMap {
		id := free
		if i%2 == 0 {
			id = i / 2
		}
		for n := 0; n < int(ch-'0'); n++ {
			blocks = append(blocks, id)
		}
	}
	return blocks
}

func checksum(blocks []int) int {
	sum := 0
	for i, id := range blocks {
		if id != free {
			sum += i * id
		}
	}
	return sum
}

// compactBlocks moves blocks one at a time from the end into the first gap.
func compactBlocks(blocks []int) []int {
	blocks = append([]int{}, blocks...)
	left, right := 0, len(blocks)-1
	for {
		for left < right && blocks[left] != free {
			left++
		}
		for left < right && blocks[right] == free {
			right--
		}
		if left >= right {
			return blocks
		}
		blocks[left], blocks[right] = blocks[right], free
	}
}

// compactFiles moves whole files, highest ID first, into the leftmost gap that fits.
func compactFiles(blocks []int) []int {
	blocks = append([]int{}, blocks...)
	end := len(blocks) - 1
	for id := blocks[len(blocks)-1]; id >= 0; id-- {
		for end >= 0 && blocks[end] != id {
			end--
		}
		start := end
		for start > 0 && blocks[start-1] == id {
			start--
		}
		size := end - start + 1
		for gap := 0; gap < start; gap++ {
			run := 0
			for gap+run < start && blocks[gap+run] == free && run < size {
				run++
			}
			if run == size {
				for k := 0; k < size; k++ {
					blocks[gap+k], blocks[start+k] = id, free
				}
				break
			}
			gap += run
		}
		end = start - 1
	}
	return blocks
}

func main() {
	blocks := layout(strings.TrimSpace(aoc.Input()))
	aoc.Answer(checksum(compactBlocks(blocks)), checksum(compactFiles(blocks)))
}
