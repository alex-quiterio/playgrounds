-- | The Intcode computer shared by the 2019 days that need it (2, 5, 7, 9, 11, 13, 15, ...).
--
-- A machine runs until it halts, produces an output, or needs an input, and
-- hands back control at each of those points so callers can wire machines
-- together (day 7) or play interactively (days 11, 13, 15).
module Intcode
  ( Machine,
    Status (..),
    parse,
    boot,
    poke,
    peek,
    step,
    run,
  )
where

import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as IntMap

data Machine = Machine
  { memory :: !(IntMap Int),
    ip :: !Int,
    relativeBase :: !Int
  }

data Status
  = Halted Machine
  | Output Int Machine
  | -- | Waiting for an input: give it one to carry on.
    Input (Int -> Machine)

-- | Reads a comma-separated program.
parse :: String -> [Int]
parse s = case break (== ',') s of
  (word, []) -> [read word | any (`elem` "-0123456789") word]
  (word, _ : rest) -> read word : parse rest

boot :: [Int] -> Machine
boot program = Machine (IntMap.fromList (zip [0 ..] program)) 0 0

-- | Memory beyond the program reads as 0.
peek :: Int -> Machine -> Int
peek address m = IntMap.findWithDefault 0 address (memory m)

poke :: Int -> Int -> Machine -> Machine
poke address value m = m {memory = IntMap.insert address value (memory m)}

-- | Runs until the machine halts, outputs, or asks for input.
step :: Machine -> Status
step m = case opcode of
  1 -> step (advance 4 (write 3 (arg 1 + arg 2)))
  2 -> step (advance 4 (write 3 (arg 1 * arg 2)))
  3 -> Input (\v -> advance 2 (write 1 v))
  4 -> Output (arg 1) (advance 2 m)
  5 -> step (if arg 1 /= 0 then jump (arg 2) else advance 3 m)
  6 -> step (if arg 1 == 0 then jump (arg 2) else advance 3 m)
  7 -> step (advance 4 (write 3 (fromEnum (arg 1 < arg 2))))
  8 -> step (advance 4 (write 3 (fromEnum (arg 1 == arg 2))))
  9 -> step (advance 2 m {relativeBase = relativeBase m + arg 1})
  99 -> Halted m
  _ -> error ("bad opcode " ++ show instruction ++ " at " ++ show (ip m))
  where
    instruction = peek (ip m) m
    opcode = instruction `mod` 100
    -- Parameter modes: 0 position, 1 immediate, 2 relative.
    mode k = instruction `div` (10 ^ (k + 1)) `mod` 10
    raw k = peek (ip m + k) m
    address k = if mode k == 2 then relativeBase m + raw k else raw k
    arg k = if mode k == 1 then raw k else peek (address k) m
    write k v = poke (address k) v m
    advance n machine = machine {ip = ip machine + n}
    jump target = m {ip = target}

-- | Runs to completion on a list of inputs, collecting every output (lazily).
run :: [Int] -> Machine -> [Int]
run inputs m = case step m of
  Halted _ -> []
  Output v next -> v : run inputs next
  Input feed -> case inputs of
    i : rest -> run rest (feed i)
    [] -> error "the program wants more input"
