module Test.Main where

import Prelude

import Exercises
import Effect (Effect)
import Effect.Class.Console (log)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main = 
  runTest do

    suite "Recursion & Arrays" do
      let
        evenInt = 100
        oddInt = 5
        toSquare = [2, 3]
        toSquareResult = [4, 9]
        toRemoveNeg = [-1, 0, 1]
        toRemoveNegResult = [0, 1]

      test "Even Integer"
        $ Assert.equal (true)
        $ isEven evenInt
      test "Odd Integer"
        $ Assert.equal (false)
        $ isEven oddInt
      test "Make squares"
        $ Assert.equal (toSquareResult)
        $ makeSquares toSquare
      test "Remove negative"
        $ Assert.equal (toRemoveNegResult)
        $ removeNeg toRemoveNeg
      test "Remove negative - alias function"
        $ Assert.equal (toRemoveNegResult)  
        $ removeNegWithAlias toRemoveNeg


    suite "Arrays, Guards, Do notation" do
      let
        primeInt = 23
        nonPrimeInt = 12
        cartesianProductArray = [1, 2]
        cartesianProductArray' = [3, 4]
        cartesianProductResult = [[1, 3], [1, 4], [2, 3], [2,4]]
        pythTriplesInt = 5
        pythTriplesResult = [[3, 4, 5]]
        factorizationsInt = 6
        factorizationsResult = [[1,6],[1,2,3]]

      test "Prime Integer"
        $ Assert.equal (true)
        $ isPrime primeInt
      test "Non prime Integer"
        $ Assert.equal (false)
        $ isPrime nonPrimeInt
      test "Cartesian product"
        $ Assert.equal (cartesianProductResult)
        $ cartesianProduct cartesianProductArray cartesianProductArray'
      test "Pythagorean triples"
        $ Assert.equal (pythTriplesResult)
        $ pythTriples (pythTriplesInt)
      test "Factorizations"
        $ Assert.equal (factorizationsResult)
        $ factorizations (factorizationsInt)

    suite "Folds & Accumulators" do
      let
        allBoolTrue = [true, true, true]
        leftReverseArray = [1, 2, 3]
        fibNum = 5
        fibResult = 8

      test "Folds"
        $ Assert.equal (true)
        $ all (allBoolTrue)
      test "Fibonacci 0"
        $ Assert.equal(1)
        $ fib 0
      test "Fibonacci 1"
        $ Assert.equal(1)
        $ fib 1
      test "Fibonacci number"
        $ Assert.equal(8)
        $ fib fibNum
      test "Tail rec Fibonacci 0"
        $ Assert.equal(1)
        $ fibTailRec 0
      test "Tail rec Fibonacci 1"
        $ Assert.equal(1)
        $ fibTailRec 1
      test "Tail rec Fibonacci number"
        $ Assert.equal(fibResult)
        $ fibTailRec fibNum


