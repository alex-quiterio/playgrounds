-- Day 6: Universal Orbit Map
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import System.Environment (getArgs)

-- | What each object orbits directly.
parse :: String -> Map String String
parse input = Map.fromList [(object, centre) | line <- lines input, (centre, _ : object) <- [break (== ')') line]]

-- | Everything an object orbits, nearest first, ending at COM.
ancestors :: Map String String -> String -> [String]
ancestors orbits object = case Map.lookup object orbits of
  Nothing -> []
  Just centre -> centre : ancestors orbits centre

main :: IO ()
main = do
  [path] <- getArgs
  orbits <- parse <$> readFile path
  -- Every direct or indirect orbit is one ancestor of some object.
  print (sum (map (length . ancestors orbits) (Map.keys orbits)))
  -- Part 2: hop down from YOU to the nearest centre SAN also orbits, then up
  -- to SAN. Its index in each ancestor list is the hops on that side.
  case (ancestors orbits "YOU", ancestors orbits "SAN") of
    (you@(_ : _), san@(_ : _)) ->
      mapM_ print (take 1 [i + j | (i, a) <- zip [0 :: Int ..] you, (j, b) <- zip [0 ..] san, a == b])
    _ -> return () -- the first example has no YOU or SAN
