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

-- <$> in an alisa for map and can be applied by enclosign in parentheses
> (<$>) (\n -> n + 1) [1, 2]
[2,3]

-- .. is defined as an alias for range in Data.Array
> import Data.Array
> range 1 5
[1,2,3,4,5]

> 1 .. 5
[1,2,3,4,5]
```

#### Filtering operator

What purpuse has the numebr in `infix 8 range as ..`, why 8? * is precedence, what does that mean?
Is it arbitrary?
```
#(..)Source
Operator alias for Data.Array.range (non-associative / precedence 8)

An infix synonym for range.

2 .. 5 = [2, 3, 4, 5]
```
From the docs[...](https://github.com/purescript/documentation/blob/master/language/Syntax.md)
*Precedence*
Precedence determines the order in which operators are bracketed. Operators with a higher precedence will be bracketed earlier. For example, take * and + from Prelude. * is precedence **7**, whereas + is precedence **6**. Therefore, if we write: `2 * 3 + 4`  is bracketed as follows `(2 * 3) + 4`. 


#### Array Comprehensions

Where `map` takes a function from values to values (possibly of a different type), `concatMap` takes a function from values to *arrays of values*. For example:
```
> import Data.Array

> :type concatMap
forall a b. (a -> Array b) -> Array a -> Array b

> concatMap (\n -> [n, n * n]) (1 .. 5)
[1,1,2,4,3,9,4,16,5,25]
```

*Think* - Python list comprehension
```python
print([[i, j] for i in range(1, 3) for j in range(i, 3)])
```

Purescript intuition
```
> :paste
… pairs n = 
…   concatMap (\i -> 1 .. n) (1 .. n)
>
> pairs 3
[1,2,3,1,2,3,1,2,3]
-- Takes from 1 to n for each i, in the range from 1 to n, so i see repeats
```

For our *pairs* case:
```
> :paste    
… pairs' n =
… -- Takes an i and a j within the n range and map construct [i, j]
…     concatMap (\i -> map (\j -> [i, j]) (1 .. n)) (1 .. n)
```

Purescript result
```
> :paste 
… pairs''' n = concatMap (\i -> map (\j -> [i, j]) (i .. n)) (1 .. n) 
…
> import Data.Foldable
> factors n = filter (\pair -> product pair == n) (pairs''' n)
> factors 10
[[1,10],[2,5]]
```

Python version
```python
print([[i, j] for i in range(1, 11) for j in range(i, 11) 
      if i*j == 10])
# 10 can be changed to n if it where to def a function
```

**`Do` notation**

We can improve readibility of the code using *do notation*:
```
factors :: Int -> Array (Array Int)
factors n = filter (\xs -> product xs == n) $ do
  i <- 1 .. n -- Binds the element of an array to a name (via <-)
  j <- i .. n
  pure [i, j] -- Does not bind element of an array
```

Do notation type of expressions:
- Bind elements of an array to a name using `<-`.
- Do not bind elements of the array to names, e.g. `pure [i, j]`.
- Expressions which give names to expressions, using the `let` keyword.#

By replacing the `<-` with the word *choose*, the above code can be read as
> "choose an element i between 1 and n, then choose an element j between i and n, and return [i, j]".

`pure` is a member of the `Applicative` type class and is defined as `pure :: forall a. a -> f a`.
The `Applicative` type class extends the `Apply` type class with a `pure` function that can be used to create values of type `f a` from values of type `a`. 

> In the case of `factors`, `pure` is applying `Array` (*is it the functor here?*) to `i` and `j`.

From the docs:
- `pure` can be seen as the function that lifts functions of zero arguments, `a -> f a`
- `Apply` provides the ability  to lift functions of two or morea arguments to functions whose
argumements are wrapped using `f`, `f (a -> b) -> f a -> f b`
- `Functor` provides the ability to lift functions of one argument, `(a -> b) -> f a -> f b`

Since `Applicative` extends `Apply` which extends `Functor` with a zero argument lift ability, `Applicative functors` can be seen as support a lifting operation for any number of function arguments.


**Guards**
We can move the `filter` function inside `do notation` by using the `guard` function.
```
guard :: forall m. MonadZero m => Boolean -> m Unit
```
`guard` returns 1 or 0 respectively if the expression passed to it evaluates to *true* or *false*.
in our context this means `guard` either returns an element, or empty.

Our definition becomes
```
import Control.MonadZero (guard)

factors :: Int -> Array Int
factors n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [i, j]
```

**Important** *if the guard fails, then the current branch of the array comprehension will terminate early with no results. This means that a call to guard is equivalent to using filter on the intermediate array.*

intuitively, it is a bit like like applying a boolean `mask` to a numpy array, and converting to `int` and filter for the 1/true values:
```python
>>> import numpy as np
>>> A = np.array([42,56,89,65,
...               99,88,42,12,
...               55,42,17,18])
>>> B = A < 15
>>> B
array([False, False, False, False, False, False, False,  True, False,
       False, False, False])
>>> B.astype(np.int)
array([0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0])
```




# Questions
#### What difference betrween apply and map?
https://spacchetti.github.io/starsuit/Data.Functor.html#v:map
`map :: forall a b. (a -> b) -> f a -> f b`
`map` *can be used to turn functions a -> b into functions f a -> f b whose argument and return types use the type constructor* `f` ...i.e. map the function a onto b

https://spacchetti.github.io/starsuit/Control.Apply.html#t:Apply
`apply :: forall a b. f (a -> b) -> f a -> f b`
`Apply` *can be used to lift functions of two or more arguments to work on values wrapped with the type constructor* `f`.

#### Lifting
- What does lift / lifting operation means? E.g. 'lift a function'
- Give the applicative context, does pure then support lifting operatiosn for any number of function arguments? Or is it other functor part of `Applicative` type class? **Any examples**? 
  - More generally: for a `functor` to be part of the `Applicative` class, it means it needs to have an operation that lift functions of two or more arguments in it (plus the additional laws as per docs)?

#### Guard
Is `Array` a Monad, and MonadZero at that?

#### Examples
Wouldn't it be great to have examples in the documentation?