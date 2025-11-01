-- Day 7: Amplification Circuit
import Data.List (permutations)
import Intcode
import System.Environment (getArgs)

-- | Wires five amplifiers in a loop, the last feeding the first, and returns
-- the last signal the final amplifier sends. Each amplifier's inputs are its
-- phase and then whatever the previous one outputs. Laziness ties the knot:
-- amplifier A reads E's outputs, which exist only as far as A has produced.
-- Without feedback (part 1) the loop simply runs once.
signal :: [Int] -> [Int] -> Int
signal program [a, b, c, d, e] = last outE
  where
    amp phase inputs = run (phase : inputs) (boot program)
    outA = amp a (0 : outE)
    outB = amp b outA
    outC = amp c outB
    outD = amp d outC
    outE = amp e outD
signal _ _ = error "five phases"

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (maximum (map (signal program) (permutations [0 .. 4])))
  print (maximum (map (signal program) (permutations [5 .. 9])))
