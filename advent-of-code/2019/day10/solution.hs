-- Day 10: Monitoring Station
import Data.List (maximumBy, sortOn, transpose)
import qualified Data.Map.Strict as Map
import Data.Ord (comparing)
import System.Environment (getArgs)

type Point = (Int, Int)

-- | The direction from a to b in lowest terms: asteroids that share it hide
-- behind each other.
direction :: Point -> Point -> Point
direction (ax, ay) (bx, by) = (dx `div` g, dy `div` g)
  where
    (dx, dy) = (bx - ax, by - ay)
    g = gcd dx dy

-- | The other asteroids seen from a station, grouped by direction and sorted
-- nearest first within each direction.
lines' :: [Point] -> Point -> Map.Map Point [Point]
lines' asteroids station =
  Map.map (sortOn distance) (Map.fromListWith (++) [(direction station a, [a]) | a <- asteroids, a /= station])
  where
    distance (x, y) = abs (x - fst station) + abs (y - snd station)

-- | Clockwise angle from straight up (y grows downward on the map).
angle :: Point -> Double
angle (dx, dy) = let a = atan2 (fromIntegral dx) (fromIntegral (negate dy)) in if a < 0 then a + 2 * pi else a

main :: IO ()
main = do
  [path] <- getArgs
  grid <- lines <$> readFile path
  let asteroids = [(x, y) | (y, row) <- zip [0 ..] grid, (x, c) <- zip [0 ..] row, c == '#']
      station = maximumBy (comparing (Map.size . lines' asteroids)) asteroids
      seen = lines' asteroids station
  print (Map.size seen)
  -- Part 2: the laser takes the nearest asteroid in each direction per turn,
  -- so the order is the directions by angle, one ring of depth at a time.
  let order = concat (transpose (map snd (sortOn (angle . fst) (Map.toList seen))))
  case drop 199 order of
    (x, y) : _ -> print (100 * x + y)
    [] -> return () -- the smaller examples have fewer than 200 asteroids
