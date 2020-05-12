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
    suite "Common Type Classes" do
      let
        myI = Complex { real: 3.0, imaginary: 1.0 }
        anotherI = Complex { real: 3.0, imaginary: 2.0 }
        someNonEmpty = NonEmpty 0 [1, 23, 44]
        anotherNonEmpty = NonEmpty 1 [1, 23, 44]


      test "Complex number"
        $ Assert.equal (false)
        $ eq myI anotherI
      test "Type constraint"
        $ Assert.equal (false)
        $ eq someNonEmpty anotherNonEmpty

    --suite "Common type classes" do
      --let

    
    --suite "Multi type classes" do
      --let