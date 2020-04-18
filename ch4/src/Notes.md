#### Introduction

Classic factorial example, in FP
```
> :paste
… fact :: Int -> Int
… fact 0 = 1
… fact n = n * fact (n-1)
…
> fact 5
120
```
When writing recursive functions is good practice to start from the base case and then build the other cases. 

#### Recursion on Arrays

Code
```
import Prelude

import Data.Array (null, tail)
import Data.Maybe (fromMaybe)

length :: forall a. Array a -> Int
length arr =
  if null arr
    then 0
    else 1 + (length $ fromMaybe [] $ tail arr)
```

More info on the functions in the above.

```
tail :: forall f a. NonEmpty f a -> f a
```
Get everything but the 'first' element of a non-empty container, *aka 'the rest'*.

Tail returns a 'Maybe' wrapping the given array without its first element.

```
fromMaybe :: forall a. a -> Maybe a -> a
```
Takes a default value, and a Maybe value. If the `Maybe` value is `Nothing` the default value is returned, otherwise the value inside the `Just` is returned.

In this case, we specify the default value as `[]` and the `Maybe` value is the valeu returned by `tail`.

**unsafePartial**

Where should I put unsafePartial?
The rule of thumb is to put unsafePartial at the level of your program such that the types tell the truth, and the part of your program responsible for making sure a use of a partial function is safe is also the part where the unsafePartial is. This is perhaps best demonstrated with an example.
https://pursuit.purescript.org/packages/purescript-partial/2.0.1

*In our case head returns Maybe type? Is it a partial function? Why docs dont mention?
If I remove firstr unsafePartial I get  an error
```
  No type class instance was found for
  
    Prim.Partial 
  

while applying a function head
  of type Partial => Array t0 -> t0
  to argument a
while checking that expression head a
  has type Int
in binding group countEvenInts

where t0 is an unknown type
```

So we need to declare unsafePartial to give t0 a type / let the compiler know what to deal with?
Waht is t0?

*class Partial*
The Partial type class is used to indicate that a function is partial, that is, it is not defined for all inputs. In practice, attempting to use a partial function with a bad input will usually cause an error to be thrown, although it is not safe to assume that this will happen in all cases. For more information, see purescript-partial.

Does this mean head acts / is defined only for the first element of an array, hence the type Partial, i.e. head return type is 'saying' Partial, so we need to infix with unsafePartial?

#### Maps

```
> map (\n -> n + 1) [1, 2]
[2,3]

-- Infix via backticks
> (\n -> n + 1) `map` [1, 2]
[2,3]

-- Infix operator <$>
> (\n -> n + 1) <$> [1, 2]
[2,3]
```