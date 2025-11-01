-- Day 23: Category Six
import qualified Data.Map.Strict as Map
import Intcode
import System.Environment (getArgs)

-- | A computer waiting for its next input.
type Node = Int -> Machine

-- | Lets a waiting computer run until it waits again with nothing left to
-- read. It reads its queued packets' values, or -1 when nothing arrived.
-- Returns everything it sent, as (destination, x, y).
service :: [Int] -> Node -> ([(Int, Int, Int)], Node)
service queue node = case queue of
  [] -> go [] (step (node (-1))) []
  v : rest -> go rest (step (node v)) []
  where
    go q status out = case status of
      Output v m -> go q (step m) (v : out)
      Input feed -> case q of
        v : rest -> go rest (step (feed v)) out
        [] -> (packets (reverse out), feed)
      Halted _ -> error "a computer halted"
    packets (d : x : y : rest) = (d, x, y) : packets rest
    packets _ = []

-- | Boots 50 computers, each told its address, and runs the network round by
-- round. Packets to 255 go to the NAT, which remembers the last one. Returns
-- the first Y the NAT receives, and the first Y it sends to computer 0 twice
-- in a row; it sends one whenever a whole round passes with no packets.
network :: [Int] -> (Int, Int)
network program = go nodes Map.empty Nothing Nothing Nothing
  where
    nodes = Map.fromList [(a, waiting (boot program) a) | a <- [0 .. 49]]
    waiting m a = case step m of
      Input feed -> case step (feed a) of
        Input feed' -> feed'
        _ -> error "a computer spoke before listening"
      _ -> error "a computer did not ask for its address"
    go machines queues nat firstY lastSent =
      let (machines', queues', sent) = foldl serve (machines, queues, []) [0 .. 49]
          toNat = [(x, y) | (255, x, y) <- sent]
          nat' = if null toNat then nat else Just (last toNat)
          firstY' = case (firstY, toNat) of
            (Nothing, (_, y) : _) -> Just y
            _ -> firstY
       in case (firstY', nat') of
            (Just y1, Just (x, y))
              | null sent && all null (Map.elems queues') ->
                  if lastSent == Just y
                    then (y1, y)
                    else go machines' (Map.insert 0 [x, y] queues') nat' firstY' (Just y)
            _ -> go machines' queues' nat' firstY' lastSent
    serve (machines, queues, sent) a =
      let (out, node) = service (Map.findWithDefault [] a queues) (machines Map.! a)
          queues' = foldl deliver (Map.insert a [] queues) out
       in (Map.insert a node machines, queues', sent ++ out)
    -- The NAT keeps its own packet, so 255 never has a queue.
    deliver q (d, x, y) = if d == 255 then q else Map.insertWith (flip (++)) d [x, y] q

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  let (first, repeated) = network program
  print first
  print repeated
