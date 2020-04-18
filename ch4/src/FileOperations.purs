module FileOperations where

import Prelude

import Data.Array
import Data.Array.Partial (head, tail) 
import Data.Maybe
-- import Data.List as DL
import Partial.Unsafe (unsafePartial) 
import Test.Assert (assert)
import Effect (Effect)

-- Ex 1
isEven :: Int -> Boolean
isEven 0 = true
isEven 1 = false
isEven n = isEven $ n - 2


-- Ex 2
countEvenInts :: Array Int -> Int
countEvenInts a =
    if null a
        then 0
        else if isEven $ unsafePartial head a               -- Checks the array's head is even
             then 1 + countEvenInts (unsafePartial tail a)  -- If true, return 1 + countEven the rest of the array
             else countEvenInts (unsafePartial tail a)      -- Else, skip the count and do as above


-- Ex 3 (1)
makeSquares :: Array Int -> Array Int
-- makeSquares a = map (\n -> n * n) a
makeSquares = map (\n -> n * n)


-- Ex 4 (2)
removeNeg :: Array Int -> Array Int
-- removeNeg = filter (\n -> n >= 0)
removeNeg = filter (_ >= 0)


-- Ex 5 (3)
-- infix 9 filter as <$?> 
-- Does not work by itself
-- Must write function signature and definition with alias first
removeNegWithAlias :: Array Int -> Array Int
removeNegWithAlias = (<$?>) (_ >= 0)
infix 9 filter as <$?> 


tests :: Effect Unit
tests = do
  assert (isEven 0 == true)
  assert (countEvenInts [0, 1, 2, 3] == 2)
  assert (makeSquares [2, 3] == [4, 9])
  assert (removeNeg [-1, 0, 1] == [0, 1])
  assert ((<$?>) (_ >= 0) [-1, 0, 1] == [0, 1])


-- multiples = filter (\n -> mod n 3 == 0 || mod n 5 == 0) ns