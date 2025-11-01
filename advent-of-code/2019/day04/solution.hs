-- Day 4: Secure Container
import Data.List (group)
import System.Environment (getArgs)

-- | Digits never decrease from left to right.
nonDecreasing :: String -> Bool
nonDecreasing digits = and (zipWith (<=) digits (drop 1 digits))

main :: IO ()
main = do
  [path] <- getArgs
  (lo, _ : hi) <- break (== '-') <$> readFile path
  -- Since the digits never decrease, equal digits always sit next to each
  -- other, so the run lengths of `group` tell us everything.
  let candidates = [map length (group s) | n <- [read lo .. read hi :: Int], let s = show n, nonDecreasing s]
  print (length (filter (any (>= 2)) candidates))
  print (length (filter (elem 2) candidates))
