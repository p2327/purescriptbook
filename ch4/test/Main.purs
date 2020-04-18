module Test.Main where

import Prelude

import FileOperations (isEven)
import Effect (Effect)
import Effect.Class.Console (log)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main = 
  runTest do
    suite "Recursion" do
      let
        a = 100
      test "Introduction"
        $ Assert.equal (true)
        $ isEven a
      -- log "🍝"
      -- log "You should add some tests."
