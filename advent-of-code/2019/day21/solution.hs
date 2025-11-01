-- Day 21: Springdroid Adventure
import Data.Char (ord)
import Intcode
import System.Environment (getArgs)

-- | Jump (J) when there is a hole in the next three squares (A, B, C) and
-- ground to land on four squares ahead (D):  J = (!A | !B | !C) & D
walk :: [String]
walk =
  [ "NOT A J",
    "NOT B T",
    "OR T J",
    "NOT C T",
    "OR T J",
    "AND D J",
    "WALK"
  ]

-- | The same jump, but only when, after landing on D, the droid can either
-- take one more step (E) or jump again straight away (H):
-- J = (!A | !B | !C) & D & (E | H)
runScript :: [String]
runScript =
  [ "NOT A J",
    "NOT B T",
    "OR T J",
    "NOT C T",
    "OR T J",
    "AND D J",
    "NOT E T", -- T = !E
    "NOT T T", -- T = E
    "OR H T", -- T = E | H
    "AND T J",
    "RUN"
  ]

-- | The hull damage the droid reports: its last output, a number too large
-- to be a character. If it falls instead, it draws the fall in ASCII.
damage :: [Int] -> [String] -> Int
damage program script = last (run (map ord (unlines script)) (boot program))

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (damage program walk)
  print (damage program runScript)
