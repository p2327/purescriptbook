module Exercises where
  
import Prelude
--import Data.Tuple
--import Data.Maybe
--import Data.Either


-- | Common Type Classes
-- | Ex 1

newtype Complex = Complex
    { real      :: Number
    , imaginary :: Number
    }

instance showComplex :: Show Complex where
    show (Complex { real, imaginary }) = 
        "Real: " <> show real <> " , Imaginary: " <> show imaginary <> "i"

instance eqComplex :: Eq Complex where
    eq (Complex c1) (Complex c2) = c1.real == c2.real && c1.imaginary == c2.imaginary


-- | Type Clas Constraints
-- | Ex 1, 2, 3

data NonEmpty a 
    = NonEmpty a (Array a)

instance eqNonEmpty :: Eq a => Eq (NonEmpty a) where
    eq (NonEmpty x xs) (NonEmpty y ys) = (eq x y) && (eq xs ys)

instance showNonEmpty :: Show a => Show (NonEmpty a) where
    show (NonEmpty x xs) = show x <> show xs
    -- show (NonEmpty x xs) = show (append [x] xs)

instance semiGroupNonEmpty :: Semigroup (NonEmpty a) where
    append (NonEmpty x xs) (NonEmpty y ys) = 
        NonEmpty x (append xs (append [y] ys))