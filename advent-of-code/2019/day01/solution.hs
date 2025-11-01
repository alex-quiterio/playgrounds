-- Day 1: The Tyranny of the Rocket Equation
import System.Environment (getArgs)

fuel :: Int -> Int
fuel mass = mass `div` 3 - 2

-- | Part 2: the fuel needs fuel too, until a step needs none.
totalFuel :: Int -> Int
totalFuel = sum . takeWhile (> 0) . drop 1 . iterate fuel

main :: IO ()
main = do
  [path] <- getArgs
  masses <- map read . lines <$> readFile path
  print (sum (map fuel masses))
  print (sum (map totalFuel masses))
