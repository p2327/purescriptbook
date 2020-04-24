module Exercises where

import Prelude

import Control.MonadZero (guard)
import Data.Array
-- import Data.Array.Partial (head, tail)
import Data.Array.Partial as DAP -- import as DAP otherwise conflicts with Data.Array
import Data.Foldable (foldl, foldr)
import Data.Maybe (Maybe(..), maybe)
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
        else if isEven $ unsafePartial DAP.head a               -- Checks the array's head is even
             then 1 + countEvenInts (unsafePartial DAP.tail a)  -- If true, return 1 + countEven the rest of the array
             else countEvenInts (unsafePartial DAP.tail a)      -- Else, skip the count and do as above


-- Ex 3 (1)
makeSquares :: Array Int -> Array Int
-- makeSquares a = map (\n -> n * n) a
makeSquares = map (\n -> n * n)


-- Ex 4 (2)
removeNeg :: Array Int -> Array Int
-- removeNeg = filter (\n -> n >= 0)
removeNeg = filter (_ >= 0)


-- Ex 5 (3)
-- Note that infix <n> filter as <$?> 
-- Does not work by itself
-- Must write function signature and definition with alias first
removeNegWithAlias :: Array Int -> Array Int
removeNegWithAlias = (<$?>) (_ >= 0)
infix 9 filter as <$?> 


-- Ex 6 (1)
factors :: Int -> Array (Array Int)
factors n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [i, j]


isPrime :: Int -> Boolean
isPrime n = 
    if n == 0
    then false
    else if factors n == [[1, n]]
         then true
         else false

-- Reasoning on the above we can write a more concise implementation
isPrime' :: Int -> Boolean
isPrime' n = (length $ factors n) == 1


-- Ex 7 (2)
{-
Pseudocode
Suppose, A = {dog, cat}
         B = {meat, milk}  
         then, 
               A×B = {(dog,meat), (dog,milk), (cat,meat), (cat,milk)}}
-}
cartesianProduct :: Array Int -> Array Int -> Array (Array Int)
cartesianProduct a b = do
   i <- a
   j <- b
   pure [i, j]


-- Ex 8 (3)
pythTriples :: Int -> Array (Array Int)
pythTriples n = do
    -- Exclude duplicate case making sure that each number only ranges from the previous to n:
    a <- 1 .. n
    b <- a .. n
    c <- b .. n
    guard $ a*a + b*b == c*c  -- Pythagorean triple constraint
    pure [a, b, c]            -- Return Array of a, b, c


-- Ex 9 (4)
-- Finds the divisors of n
-- divisors :: Int -> Array (Array Int)
divisors :: Int -> Array Int
divisors n = do
  i <- 1 .. n
  guard $ mod n i == 0
  pure i
  -- pure [i]


-- Find prime numbers among divisors of n
primeDivisors :: Int -> Array Int
primeDivisors n = do
    i <- 2 .. n
    guard $ mod n i == 0 && isPrime i
    pure i


-- All combinations of factors in range n which product gives n
allFactors:: Int -> Array (Array Int)
allFactors 1 = [[1]]
allFactors n = do
    i <- 1 .. (n - 1)      -- Choose an i in the Array of range 1 to n-1
    guard $ mod n i == 0   -- Mask for divisors of n 
    k <- allFactors i      -- Choose a k among the divisors (k is an Array) and call on i 
    pure $ snoc k $ n / i -- Divide n by i, append to and return the array of k-s


factorizations :: Int -> Array (Array Int)
-- Takes allFactors, sort each, remove duplicates with nub
-- The array must be sorted to be passed to nub (nub :: forall a. Ord a => ...)
factorizations = nub <<< map sort <<< allFactors


-- Find just the prime factors
factorize :: Int -> Array Int
factorize 1 = []
factorize n = maybe [n] (\a -> a : factorize (n `div` a)) mf 
  where
        mf = head $ filter (\x -> (n `mod` x) == 0) (2 .. (n - 1)) 


-- Ex 10
{-
(&&)
Returns the logical conjunction of both arguments.

true && false -- false
true && true -- true
-}
all :: forall a. Array Boolean -> Boolean
-- Takes each value in a Boolean array and compare to default value true
-- all boolArray = foldl (&&) true boolArray
-- Eta reduced:
all = foldl (&&) true


-- Ex 11
leftReverse :: forall a. Array a -> Array a
leftReverse = foldl (\emptyArray arrayElem -> [arrayElem] <> emptyArray) [] 



-- Ex 12
-- Non tail-recursive Fibonacci implementations
fib :: Int -> Int
fib 0 = 1
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)


-- Tail recursive Fibonacci with accumulator pattern (curr)
-- pred = predecessor, curr = current Fibonacci number
fibTailRec :: Int -> Int
fibTailRec n = go n 0 1
    where
        go :: Int -> Int -> Int -> Int
        go 0 pred curr = curr
        go n pred curr = go (n - 1) (curr) (pred + curr)


-- Cumulative assertions to build test/Main.purs with
tests :: Effect Unit
tests = do
  assert (isEven 0 == true)
  assert (countEvenInts [0, 1, 2, 3] == 2)
  assert (makeSquares [2, 3] == [4, 9])
  assert (removeNeg [-1, 0, 1] == [0, 1])
  assert ((<$?>) (_ >= 0) [-1, 0, 1] == [0, 1])
  assert (factors 5 == [[1, 5]])
  assert (isPrime 5 == true)
  assert (isPrime 10 == false)
  assert (isPrime' 5 == true)
  assert (isPrime' 10 == false)
  assert (cartesianProduct [1, 2] [3, 4] == [[1, 3], [1, 4], [2, 3], [2,4]])
  assert (pythTriples 5 == [[3, 4, 5]])
  assert (divisors 12 == [1, 2, 3, 4, 6, 12])
  assert (primeDivisors 12 == [2, 3])
  assert (primeDivisors 23 == [23])
  assert (allFactors 6 == [[1,6],[1,2,3],[1,3,2]])
  assert (factorizations 6 == [[1,6],[1,2,3]])
  assert (factorize 6 == [2, 3])
  assert (all [true, true, true] == true)
  assert (leftReverse [1, 2, 3] == [3, 2, 1])
  assert (fib 0 == 1)
  assert (fib 1 == 1)
  assert (fib 5 == 8)
  assert (fibTailRec 0 == 1)
  assert (fibTailRec 1 == 1)
  assert (fibTailRec 5 == 8)