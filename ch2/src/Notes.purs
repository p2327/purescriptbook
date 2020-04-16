module Notes where

import Prelude
--import Control.Monad.Eff.Console (log)
--import TryPureScript
--import Math (sqrt)

myTypes :: Int
myTypes = 1

addMe :: Int -> Int  -> Int
-- This is like lambda a, lambda b ?
addMe = \a -> \b -> a + b
-- This is like lambda a, b
addMe2 :: Int -> Int -> Int
addMe2 = \a b -> a + b
-- I can also do
addMe3 :: Int -> Int -> Int
addMe3 a b = a + b 
-- This is like lambda a, b, c
addThree :: Int -> Int -> Int -> Int
addThree = \a b c -> a + b + c
-- addMe a b c = a + b + c

-- import Effect.Console (log)

greet :: String -> String
greet name = "Hello " <> name <> "!"
-- greet name = "Hi, " <> name 

