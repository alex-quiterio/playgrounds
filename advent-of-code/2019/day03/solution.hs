-- Day 3: Crossed Wires
import qualified Data.Map.Strict as Map
import System.Environment (getArgs)

type Point = (Int, Int)

splitOn :: Char -> String -> [String]
splitOn c s = case break (== c) s of
  (word, []) -> [word]
  (word, _ : rest) -> word : splitOn c rest

-- | Every point a wire visits, mapped to the steps it took to get there first.
trace :: String -> Map.Map Point Int
trace path = Map.fromListWith min (zip points [1 ..])
  where
    points = drop 1 (scanl move (0, 0) (concatMap expand (splitOn ',' path)))
    expand (dir : n) = replicate (read n) dir
    expand [] = []
    move (x, y) dir = case dir of
      'R' -> (x + 1, y)
      'L' -> (x - 1, y)
      'U' -> (x, y + 1)
      _ -> (x, y - 1)

main :: IO ()
main = do
  [path] <- getArgs
  [a, b] <- map trace . filter (not . null) . lines <$> readFile path
  let crossings = Map.intersectionWith (+) a b
  print (minimum [abs x + abs y | (x, y) <- Map.keys crossings])
  print (minimum (Map.elems crossings))
