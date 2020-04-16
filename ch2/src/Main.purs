-- Every file begins with a module header. 
module Main where

import Prelude

-- Import effet for main type declaration
import Effect (Effect)
-- Import logShow for diagonal exercise
import Effect.Console (log, logShow)
import Math (sqrt, pi)

-- main = do

diagonal :: Number -> Number -> Number 
diagonal w h = sqrt (w * w + h * h)


circleArea :: Number -> Number
circleArea = \r -> pi * r * r
{-
Also valid:
circleArea r = pi * r * r
-}

{-
The main program is defined as a function application.

Function application is indicated with whitespace separating 
the function name from its arguments.
-}
-- main =  log "Hello World!"
main :: Effect Unit
main = logShow (circleArea 4.0)
-- logShow (diagonal 3.0 4.0)
-- log "Hello World!"