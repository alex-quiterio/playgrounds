-- Day 25: Cryostasis
import Data.Char (chr, isDigit, ord)
import Data.List (isInfixOf, isPrefixOf, subsequences)
import qualified Data.Set as Set
import Intcode
import System.Environment (getArgs)

-- | Types a command (or nothing) and reads everything the droid prints until
-- it waits for the next one. Nothing as the machine means the game ended.
--
-- When the droid asks for input we hand back the machine from before that
-- step: running it again reaches the same prompt, and no output can sit in
-- between because `step` stops at every output.
say :: String -> Machine -> (String, Maybe Machine)
say typed = go (map ord typed) []
  where
    go inputs acc m = case step m of
      Halted _ -> (reverse acc, Nothing)
      Output v m' -> go inputs (chr v : acc) m'
      Input feed -> case inputs of
        i : rest -> go rest acc (feed i)
        [] -> (reverse acc, Just m)

command :: String -> Machine -> (String, Machine)
command c m = case say (c ++ "\n") m of
  (out, Just m') -> (out, m')
  (out, Nothing) -> error ("the game ended after " ++ show c ++ ":\n" ++ out)

data Room = Room {name :: String, doors :: [String], items :: [String]}

-- | Reads the last room description in the droid's output.
room :: String -> Room
room out = Room title (listAfter "Doors here lead:") (listAfter "Items here:")
  where
    ls = lines out
    titles = [trimTitle l | l <- ls, "== " `isPrefixOf` l]
    trimTitle = reverse . drop 3 . reverse . drop 3
    title = if null titles then "" else last titles
    -- Only the last description counts (the checkpoint can throw us back).
    lastPart = reverse (takeWhile (not . ("== " `isPrefixOf`)) (reverse ls))
    listAfter header = [drop 2 l | l <- takeWhile (/= "") (drop 1 (dropWhile (/= header) lastPart)), "- " `isPrefixOf` l]

-- | Items that end the game or trap the droid if you pick them up.
dangerous :: [String]
dangerous = ["giant electromagnet", "infinite loop", "molten lava", "escape pod", "photons"]

back :: String -> String
back d = case d of
  "north" -> "south"
  "south" -> "north"
  "east" -> "west"
  _ -> "east"

-- | What exploring found: rooms seen, items carried, and the way to the
-- security checkpoint plus the door from it onto the pressure-sensitive floor.
data Found = Found {seen :: Set.Set String, carried :: [String], checkpoint :: Maybe ([String], String)}

-- | Depth-first walk of the ship. `path` is how we got here from the start;
-- every room is left the way it was entered, so the droid ends up back home.
explore :: [String] -> String -> Machine -> Found -> (Machine, Found)
explore path arrival m found
  | name here == "Security Checkpoint" =
      let floorDoor = case [d | d <- doors here, Just d /= fmap back (lastMaybe path)] of
            d : _ -> d
            [] -> error "no way onto the floor"
       in (m, found' {checkpoint = Just (path, floorDoor)})
  | otherwise = foldl walk (m', found' {carried = carried found ++ safe}) exits
  where
    here = room arrival
    found' = found {seen = Set.insert (name here) (seen found)}
    safe = filter (`notElem` dangerous) (items here)
    m' = foldl (\machine item -> snd (command ("take " ++ item) machine)) m safe
    exits = [d | d <- doors here, Just d /= fmap back (lastMaybe path)]
    walk (machine, f) d =
      let (out, there) = command d machine
       in if Set.member (name (room out)) (seen f)
            then (snd (command (back d) there), f)
            else
              let (done, f') = explore (path ++ [d]) out there f
               in (snd (command (back d) done), f')
    lastMaybe xs = if null xs then Nothing else Just (last xs)

-- | At the checkpoint, tries every combination of items until the floor lets
-- the droid through; the airlock password is the number in that message.
password :: Machine -> [String] -> String -> String
password m held floorDoor = case [out | combo <- subsequences held, let out = attempt combo, not ("Alert!" `isInfixOf` out)] of
  out : _ -> takeWhile isDigit (dropWhile (not . isDigit) (snd (breakOn "typing " out)))
  [] -> error "no combination of items works"
  where
    attempt combo =
      let dropped = foldl (\machine item -> snd (command ("drop " ++ item) machine)) m (filter (`notElem` combo) held)
       in fst (say (floorDoor ++ "\n") dropped)
    breakOn needle s = case s of
      [] -> ([], [])
      _ | needle `isPrefixOf` s -> ([], s)
      c : rest -> let (a, b) = breakOn needle rest in (c : a, b)

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  let (intro, start) = case say "" (boot program) of
        (out, Just m) -> (out, m)
        (_, Nothing) -> error "the game ended at once"
      (home, found) = explore [] intro start (Found Set.empty [] Nothing)
  case checkpoint found of
    Nothing -> error "never found the security checkpoint"
    Just (route, floorDoor) -> do
      let atCheckpoint = foldl (\machine d -> snd (command d machine)) home route
      putStrLn (password atCheckpoint (carried found) floorDoor)
