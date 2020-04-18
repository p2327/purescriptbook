module FileOperations where

import Prelude

import Data.Array
import Data.Array.Partial (head, tail) 
import Data.Maybe
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
        else if isEven $ unsafePartial head a               -- check the head is even
             then 1 + countEvenInts (unsafePartial tail a)  -- if true, return 1 + countEven the rest of the array
             else countEvenInts (unsafePartial tail a)      -- if false, skip the count and do as above




tests :: Effect Unit
tests = do
  assert (isEven 0 == true)
  assert (countEvenInts [0, 1, 2, 3] == 2)


-- multiples = filter (\n -> mod n 3 == 0 || mod n 5 == 0) ns