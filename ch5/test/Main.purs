module Test.Main where

import Prelude

import Exercises
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)


main :: Effect Unit
main = 
  runTest do
    suite "Pattern matching" do
      let
        location = {street:"Long drive", city:"Los Angeles"}
        location' = {street: "Acacia Grove", city:"Boston"}
        marl = {firstName: "Marl", lastName: "Smith", address: location}
        john = {firstName: "John", lastName: "Goof", address: location}
        irv = {firstName: "Irvine", lastName: "Dolittle", address: location'}
 
      test "Matching address"
        $ Assert.equal (true)
        $ sameCity marl john
      test "Different address"
        $ Assert.equal (false)
        $ sameCity john irv
    
    --suite "ADTs" do
      --let
        



