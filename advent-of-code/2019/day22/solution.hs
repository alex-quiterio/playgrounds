-- Day 22: Slam Shuffle
import System.Environment (getArgs)

-- | A shuffle sends the card at position p to position (a * p + b) mod n.
-- Every technique is such a linear map, and so is any sequence of them.
data Linear = Linear Integer Integer

-- | The map for one technique on a deck of n cards.
technique :: Integer -> String -> Linear
technique n line = case words line of
  ["deal", "into", "new", "stack"] -> Linear (-1) (n - 1)
  ["cut", k] -> Linear 1 (negate (read k))
  ["deal", "with", "increment", k] -> Linear (read k) 0
  _ -> error ("unknown technique: " ++ line)

-- | `andThen n f g` applies f first, then g.
andThen :: Integer -> Linear -> Linear -> Linear
andThen n (Linear a b) (Linear c d) = Linear (c * a `mod` n) ((c * b + d) `mod` n)

apply :: Integer -> Linear -> Integer -> Integer
apply n (Linear a b) p = (a * p + b) `mod` n

-- | The whole process, composed into one map.
shuffle :: Integer -> [String] -> Linear
shuffle n = foldl (\f line -> andThen n f (technique n line)) (Linear 1 0)

-- | The map applied k times, by repeated squaring.
power :: Integer -> Linear -> Integer -> Linear
power _ _ 0 = Linear 1 0
power n f k
  | even k = power n (andThen n f f) (k `div` 2)
  | otherwise = andThen n f (power n f (k - 1))

-- | x ^ e mod n.
modPow :: Integer -> Integer -> Integer -> Integer
modPow _ _ 0 = 1
modPow n x e
  | even e = modPow n (x * x `mod` n) (e `div` 2)
  | otherwise = x * modPow n x (e - 1) `mod` n

-- | The inverse map: which position ends up at p. The deck size is prime,
-- so a has an inverse a ^ (n - 2) by Fermat's little theorem.
invert :: Integer -> Linear -> Linear
invert n (Linear a b) = Linear inv ((negate b * inv) `mod` n)
  where
    inv = modPow n a (n - 2)

main :: IO ()
main = do
  [path] <- getArgs
  steps <- filter (not . null) . lines <$> readFile path
  -- Part 1: where card 2019 ends up in a deck of 10007.
  let small = 10007
  print (apply small (shuffle small steps) 2019)
  -- Part 2: the card at position 2020 after the process runs a huge number
  -- of times on a huge deck: undo the repeated shuffle on position 2020.
  let big = 119315717514047
      times = 101741582076661
  print (apply big (invert big (power big (shuffle big steps) times)) 2020)
