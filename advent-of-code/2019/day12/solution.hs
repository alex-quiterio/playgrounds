-- Day 12: The N-Body Problem
import Data.Char (isDigit)
import Data.List (transpose)
import System.Environment (getArgs)

-- | Positions and velocities of every moon along one axis. The axes never
-- affect each other, so each is simulated on its own.
type Axis = ([Int], [Int])

numbers :: String -> [Int]
numbers s = case dropWhile (\c -> not (isDigit c || c == '-')) s of
  [] -> []
  rest -> let (n, more) = span (\c -> isDigit c || c == '-') rest in read n : numbers more

-- | Gravity pulls each pair one step closer, then every moon moves.
step :: Axis -> Axis
step (ps, vs) = (zipWith (+) ps vs', vs')
  where
    vs' = zipWith (+) vs [sum [signum (q - p) | q <- ps] | p <- ps]

energy :: [Axis] -> Int
energy axes = sum (zipWith (*) (map (sum . map abs) (transpose (map fst axes))) (map (sum . map abs) (transpose (map snd axes))))

-- | Steps until an axis comes back to its start. Each step can be undone, so
-- the first repeat is always the starting state.
period :: Axis -> Int
period start = 1 + length (takeWhile (/= start) (drop 1 (iterate step start)))

main :: IO ()
main = do
  [path] <- getArgs
  moons <- map numbers . filter (not . null) . lines <$> readFile path
  let axes = [(ps, map (const 0) ps) | ps <- transpose moons]
  print (energy (map (\a -> iterate step a !! 1000) axes))
  print (foldr1 lcm (map period axes))
