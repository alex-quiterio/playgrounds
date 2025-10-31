// Package aoc has the small helpers shared by the 2024 solutions.
package aoc

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

// Input returns the contents of the file named on the command line.
func Input() string {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: ./run INPUT")
		os.Exit(2)
	}
	data, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	return string(data)
}

// Lines splits text into non-empty lines.
func Lines(text string) []string {
	var lines []string
	for _, line := range strings.Split(strings.ReplaceAll(text, "\r\n", "\n"), "\n") {
		if line != "" {
			lines = append(lines, line)
		}
	}
	return lines
}

var integer = regexp.MustCompile(`-?\d+`)

// Ints returns every integer in s.
func Ints(s string) []int {
	var numbers []int
	for _, match := range integer.FindAllString(s, -1) {
		n, _ := strconv.Atoi(match)
		numbers = append(numbers, n)
	}
	return numbers
}

// Point is a grid position.
type Point struct{ R, C int }

// Add returns p moved by d.
func (p Point) Add(d Point) Point { return Point{p.R + d.R, p.C + d.C} }

// Grid is a rectangular character map.
type Grid []string

// In reports whether p is on the grid.
func (g Grid) In(p Point) bool {
	return p.R >= 0 && p.R < len(g) && p.C >= 0 && p.C < len(g[p.R])
}

// At returns the byte at p, or 0 outside the grid.
func (g Grid) At(p Point) byte {
	if !g.In(p) {
		return 0
	}
	return g[p.R][p.C]
}

// Answer prints each part's answer on its own line.
func Answer(parts ...any) {
	for _, part := range parts {
		fmt.Println(part)
	}
}
