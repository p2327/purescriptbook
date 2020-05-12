module Exercises where
  
import Prelude
import Data.Array
import Data.Foldable (foldl, foldr)
import Data.Maybe (Maybe(..), maybe, fromJust, fromMaybe)
import Data.Picture
import Partial.Unsafe (unsafePartial) 


type Address = 
    { street :: String
    , city :: String
    }

type Person = {
    firstName :: String,
    lastName :: String,
    address :: Address
}


-- Row polymorphism

-- Untyped function
showPerson { first: x, last: y } = y <> ", " <> x

-- Typed functions does not allow | r fields
showPerson' :: { first :: String, last :: String }  -> String
showPerson' { first: x, last: y } = x <> ", " <> y

showPerson'' :: Person  -> String
showPerson'' { firstName: x, lastName: y } = x <> ", " <> y


-- Ex 1
sameCity :: Person -> Person -> Boolean
sameCity x y
    | x.address.city == y.address.city = true
    | otherwise = false

sameCity' :: Person -> Person -> Boolean
sameCity' { address: { city: x } } { address: { city: y } } = x == y


-- Ex 2
-- A bit like unpacking a Python list, just type-sensitive
fromSingleton :: forall a. a -> Array a -> a
fromSingleton _ [x] = x
fromSingleton default _ = default


-- Alternative with Maybe
fromSingleton' :: forall a. a -> Array a -> Maybe a
fromSingleton' _ [x] = Just x
fromSingleton' x _ = Nothing


-- Ex 1 (1)
origin :: Point
origin = Point { x: 0.0
               , y: 0.0 
               }

myCircle :: Shape
myCircle = Circle centre radius
    where 
    centre :: Point
    centre = origin
    radius :: Number
    radius = 10.0


conciseCircle :: Shape
conciseCircle = Circle origin 10.0

-- Ex 2 (1)
-- Guards ?
{-
scaleUp :: Shape -> Shape
scaleUp shape a b | r
    | Circle c r = Circle origin (r * 2.0)
    | Rectangle p w h = Rectangle origin (w * 2.0) (h * 2.0)
    | Line start end  = Line (start + 2.0) (end + 2.0)
    | Text p text  = Text origin text
-}

-- Pattern matching
scaleShape :: Shape -> Shape
scaleShape (Circle p r) = Circle origin (r * 2.0)
scaleShape (Rectangle p w h) = Rectangle origin (w * 2.0) (h * 2.0)
scaleShape (Line (Point start) (Point end)) = Line newStart newEnd
  where
    newStart = origin
    newEnd = Point {x: end.x * 2.0, y: end.y * 2.0}
scaleShape (Text p text) = Text origin text


-- using case expression
scaleUp :: Shape -> Shape
scaleUp s = case s of 
            Circle c r -> Circle origin (r * 2.0)
            Rectangle c w h-> Rectangle origin (w * 2.0) (h * 2.0)
            Line (Point start) (Point end) -> Line origin newEnd
                where
                newEnd = Point {x: end.x * 2.0, y: end.y * 2.0}
            Text p text -> Text origin text


-- Ex 3 (1)
showText :: Shape -> Maybe String
showText t = case t of
             Text p s -> Just s
             _ -> Nothing


-- Ex 1 (2)
area :: Shape -> Number
area s = case s of 
         Circle c r -> 3.14 * r * r
         Rectangle c w h-> w * h
         Line (Point start) (Point end) -> 1.0
         Text p text -> 0.0


-- Ex (2)


