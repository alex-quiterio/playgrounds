-- Day 14: Space Stoichiometry
import qualified Data.List as List
import Data.Map.Strict (Map, (!))
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import System.Environment (getArgs)

-- | Each chemical's reaction: how much one run makes, and what it takes.
type Reactions = Map String (Int, [(Int, String)])

parse :: String -> Reactions
parse input =
  Map.fromList
    [ (out, (read n, pairs ins))
    | line <- lines input
    , (ins, ["=>", n, out]) <- [break (== "=>") (words (filter (/= ',') line))]
    ]
  where
    pairs (n : chem : rest) = (read n, chem) : pairs rest
    pairs _ = []

-- | Chemicals ordered so each comes before everything it is made from.
order :: Reactions -> [String]
order reactions = fst (visit ([], Set.empty) "FUEL")
  where
    visit (done, seen) chem
      | chem `Set.member` seen || chem == "ORE" = (done, seen)
      | otherwise =
          let (done', seen') = List.foldl' visit (done, Set.insert chem seen) (map snd (snd (reactions ! chem)))
           in (chem : done', seen')

-- | Ore needed for some fuel. Going down the order, every use of a chemical
-- is known before it is made, so leftovers are never wasted.
oreFor :: Reactions -> [String] -> Int -> Int
oreFor reactions chems fuel = Map.findWithDefault 0 "ORE" (List.foldl' make (Map.singleton "FUEL" fuel) chems)
  where
    make need chem =
      let (made, inputs) = reactions ! chem
          runs = (Map.findWithDefault 0 chem need + made - 1) `div` made
       in List.foldl' (\m (n, c) -> Map.insertWith (+) c (n * runs) m) need inputs

main :: IO ()
main = do
  [path] <- getArgs
  reactions <- parse <$> readFile path
  let chems = order reactions
      ore = oreFor reactions chems
      budget = 1000000000000
      -- Part 2: binary search for the most fuel the ore budget covers.
      search lo hi
        | lo >= hi = lo
        | otherwise = let mid = (lo + hi + 1) `div` 2 in if ore mid <= budget then search mid hi else search lo (mid - 1)
  print (ore 1)
  print (search 0 budget)
