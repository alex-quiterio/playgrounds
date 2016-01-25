package main;

import (
  "fmt"
)

type Puddle struct {
  X int
  XPos int
  Y int
  YPos int
}

func (p* Puddle) inspect() {
  fmt.Printf("X: %d, XPos: %d, Y:%d, YPos:%d\n", p.X, p.XPos, p.Y, p.YPos);
}

func (p* Puddle) valid() bool {
  return p.X != 0
}

func isLocalMax(montain[]int, x int) bool {

  currentX  := montain[x]
  XPlusOne, XMinusOne := 0, 0

  if (x+1) < len(montain) { XPlusOne = montain[x+1] }
  if x > 0 { XMinusOne = montain[x-1] }

  return (currentX >= XPlusOne && currentX > XMinusOne) || (currentX > XPlusOne && currentX >= XMinusOne)
}

func rightLocalMax(montain[] int, x int) bool {
  currentX  := montain[x]
  XPlusOne, XMinusOne := 0, 0

  if (x+1) < len(montain) { XPlusOne = montain[x+1] }
  if x > 0 { XMinusOne = montain[x-1] }

  return currentX > XPlusOne && currentX >= XMinusOne
}

func onlyValidPuddles(oldPuddles []Puddle) []Puddle {

  currentPuddle, validPuddles := 0, 0

  for i := 0; i < len(oldPuddles); i++ {
    if oldPuddles[i].valid() { validPuddles++ }
  }

  newPuddles := make([]Puddle, validPuddles)

  for i := 0; i < len(oldPuddles); i++ {
    if oldPuddles[i].valid() {
      newPuddles[currentPuddle] = oldPuddles[i]
      currentPuddle++
    }
  }
  return newPuddles
}

func greater(value int, coord int, puddles []Puddle) bool {
  for _, puddle := range puddles {
    if puddle.XPos >= coord && puddle.X > value {
      return false;
    }
  }
  return true;
}

func normalizePuddles(oldPuddles []Puddle) []Puddle {

  puddles := make([]Puddle, len(oldPuddles))
  copy(puddles, oldPuddles)

  for i:= 0; i < len(puddles)-1; i++ {
    left:= puddles[i]

    for j := i+1; j < len(puddles); j++ {
      right := puddles[j]

      if left.Y > right.X && right.Y > left.Y {
        oldPuddles[i] = Puddle { left.X, left.XPos, right.Y, right.YPos }
        oldPuddles[j].X = 0
      } else if left.Y > right.X && greater(right.X, right.XPos, puddles) {
        oldPuddles[i] = Puddle { left.Y, left.YPos, right.X, right.XPos }
        oldPuddles[j].X = 0
      } else {
        break
      }
    }
  }
  return oldPuddles
}

func findPuddles(montain []int) []Puddle {

  currentPuddle, leftMax, leftPos := 0, 0, 0
  puddles := make([]Puddle, len(montain))

  for position, value := range montain {
     if isLocalMax(montain, position) {
        if leftPos != 0 {
	         puddles[currentPuddle] = Puddle{leftMax, leftPos,value, position}
           if rightLocalMax(montain, position) && leftMax <= value {
            leftPos, leftMax = position, value
           } else {
            leftPos, leftMax = 0, 0
           }
           currentPuddle++
        } else {
          leftMax, leftPos = value, position
        }
     }
  }
  if leftMax != 0 && leftPos != 0 {
    puddles[currentPuddle+1] = Puddle{leftMax, leftPos,0, 0}
  }

  return onlyValidPuddles(normalizePuddles(onlyValidPuddles(puddles)))
}

func twitterPuddle(montain []int, expectedValue int) {
  puddles := findPuddles(montain)
  waterRetained := 0
  for _, puddle := range puddles {
    for i := puddle.XPos+1; i < puddle.YPos; i++ {
      if (puddle.X <= puddle.Y ) { waterRetained += puddle.X - montain[i] }
      if (puddle.X > puddle.Y )  { waterRetained += puddle.Y - montain[i] }
    }
  }
  if (expectedValue != waterRetained) {
    fmt.Printf("[L] Expected Value: %d, Water retained: %d\n", expectedValue, waterRetained)
  } else {
    fmt.Printf("[W] Total Retained Water Value: %d!\n", waterRetained)
  }
}

func main() {
  twitterPuddle([]int{ 2, 5, 1, 2, 3, 4, 7, 7, 6 }, 10)
  twitterPuddle([]int{ 2, 5, 1, 2, 3, 4, 7, 7, 6, 5, 4, 4, 4, 2, 3 }, 11)
  twitterPuddle([]int{ 2, 5, 1, 3, 1, 2, 1, 7, 7, 6}, 17)
  twitterPuddle([]int{ 2, 7, 2, 7, 4, 7, 1, 7, 3, 7}, 18)
  twitterPuddle([]int{ 7, 7, 7, 2, 7, 7, 7, 7, 7, 7, 7}, 5)
  twitterPuddle([]int{ 6, 7, 7, 4, 3, 2, 1, 5, 2}, 10)
  twitterPuddle([]int{ 2, 5, 1, 2, 3, 4, 7, 6, 2, 7, 1, 2, 3, 4, 5, 4}, 26)
}
