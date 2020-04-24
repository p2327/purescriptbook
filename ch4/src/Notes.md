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


#### Folds
`foldable` represent a data structure that can be *folded*.

In other languages this is often referred as *reduce*.
For example, in Python
```python
>>> from functools import reduce
>>> reduce(lambda x, y: x + y, [1, 2, 3, 4, 5])
15
```

Purescript signatures:
```
> import Data.Foldable

> :type foldl
forall a b f. Foldable f => (b -> a -> b) -> b -> f a -> b

> :type foldr
forall a b f. Foldable f => (a -> b -> b) -> b -> f a -> b
```

In case of Arrays, we can write more specifically:
```
> :type foldl
forall a b. (b -> a -> b) -> b -> Array a -> b

> :type foldr
forall a b. (a -> b -> b) -> b -> Array a -> b
```

Arguments:
- `a` is the type of elements in our `Foldable` (here: a=`Int`, foldable=`Array`)
- `b` is the type of an *accumulator*, which accumulates result as we traverse the data structure.
- `(b -> a -> a)` and `(a -> b -> b)` are functions (left to right, and right to left, respectively) which are applied onto each element and the result *stored* into the accumulator. 

For example, if we want to sum an array of integers, we will:
1. Provide a function argument of signature `Int -> Int -> Int`, i.e. `(+)`
2. Provide an initial value for the accumulator, here `0`
3. Provide the `Array Int` we want to sum

In other words, the function takes an Int (default value for accumulator b), an element a (Int) of an Array we wantto sum, and returns a Int (accumulator result b).

With the above we can define a function that sums arrays of `Int`s like so:
```
> :paste
… sumArray :: Array Int -> Int
… sumArray = foldl (+) 0 
…
> sumArray (1..5)
15
```

To understand l and r orientation:
```
-- foldl (b -> a -> b) (String -> Int -> String) empty string (default for b) Array a
> foldl (\acc n -> acc <> show n) "" [1,2,3,4,5]
"12345"

-- foldr (a -> b -> b) (Int -> String -> String) empty string (default for b) Array a
> foldr (\n acc -> acc <> show n) "" [1,2,3,4,5]
"54321"
```

#### Tail recursion
A call is in *tail position* when it is the last call made before a function returns. In other words, the *"return statement"* is only the recursive call and nothing else. 

A recursive call in tail recursion can *skip* the frames before the last, so returning the value without moving back to do the computation for the answer.

Tail recursive factorial in Purescript:
```
fact :: Int -> Int -> Int
fact 0 total = total
fact n total = fact (n - 1) (total * n)
```

Tail recursive factorial in Python;
```python
# Here the last frame has the result, and we just return that
def factorial(n):
    def fact_helper(n, total):
        if n == 1:
            return total
        return fact_helper(n - 1, total * n)
    return fact_helper(n, 1)
```

**Accumulators**
One common way to turn a function which is not tail recursive into a tail recursive function is to use an accumulator parameter.

An additional parameter which is added to a function which accumulates a return value, as opposed to using the return value to accumulate the result.

To visualise, run this in Pythontutor and examine the frames and how the value is returned.
```
def factorial(n):
    def fact_helper(n, total):
        if n == 1:
            return total
        return fact_helper(n - 1, total * n)
    return fact_helper(n, 1)
    
def factorial_ntr(n):
    if n == 0 or n == 1:
        return 1
    else:
        return n * factorial_ntr(n-1)

print(factorial(5), factorial_ntr(5))
```

***Prefer fold to explicit recursion***
Writing algorithms directly in terms of combinators such as map and fold has the added advantage of code simplicity - these combinators are well-understood, and as such, communicate the intent of the algorithm much better than explicit recursion.

For example, we can reverse an array using foldr:

```
> import Data.Foldable

> :paste
… reverse :: forall a. Array a -> Array a
… reverse = foldr (\x xs -> xs <> [x]) []
… ^D

> reverse [1, 2, 3]
[3,2,1]
```

With foldl
```
> :paste                                         
… leftReverse :: forall a. Array a -> Array a     
… leftReverse = foldl (\emptyA elem -> [elem] <> emptyA) []     
…
> leftReverse [1,2,3]                          
[3,2,1]
```
Where 
- emptyA is `b` of type `Array` of `a`, here `Array Int`
- elem is `a` of type `Int`
- default for `b` is `[]`
- takes all (`forall`) elem of type `a` from an argument (here, [1, 2, 3])
- returns an `Array of a`, which is type `b`


#### Questions
**Difference between apply and map**
https://spacchetti.github.io/starsuit/Data.Functor.html#v:map
`map :: forall a b. (a -> b) -> f a -> f b`
`map` *can be used to turn functions a -> b into functions f a -> f b whose argument and return types use the type constructor* `f`

> So if I understand correctly, `map` takes a function `(a -> b)`, a `functor f a` (a type constructor, like `Maybe`) and applies the function and returns a new `functor f b` ?
For example
```
> map (\n -> n + 3) (Just 5)
(Just 8)

> (\n -> n + 3) <$> Just
(Just 8)
```

https://spacchetti.github.io/starsuit/Control.Apply.html#t:Apply
`apply :: forall a b. f (a -> b) -> f a -> f b`
`Apply` *can be used to lift functions of two or more arguments to work on values wrapped with the type constructor* `f`.

> So here I apply a function wrapped in a context (e.g. `Maybe` functor/type constructor) to a value or values wrapped with the same type constructor ?
For example
```
> apply (Just (\n -> n + 3)) (Just 5)
(Just 8)

> Just (\n -> n + 3) <*> Just 5      
(Just 8)
```
Does this means `Apply` is an `Applicative`? Going by the definition of applying a *function* wrapped in a context to a *value* wrapped in a context?

How do I write these
```
> (*) <$> Just 5 <*> Just 3         
(Just 15)

> lift2 (*) (Just 5) (Just 3)       
(Just 15)
```
with `apply`?

Can anyone make some example of when this is used in practice?



**Applicative**
- Does `pure` support lifting opoperations for any number of function arguments? Or is it other functor(s) part of `Applicative` typeclass? **Any examples**? 
  - More generally: for a `functor` to be part of the `Applicative` class, it means it needs to have an operation that lift functions of two or more arguments in it (plus the additional laws as per docs)?

**Guard**
Is `Array` a of MonadZero typeclass?

I am not clear what happens here in the book:
```
> import Control.MonadZero

> :type guard
forall m. MonadZero m => Boolean -> m Unit
```
And then
*we can assume that PSCi reported the following type:*
`Boolean -> Array Unit`

Does m stand for monad, so Array is a monad?

**Examples**
Wouldn't it be great to have additional concrete examples of functions usage in the documentation?

Some have, some don't -- I think it would be great to enrich the docs. For example this is immediate:
```
cons
cons :: forall a. a -> Array a -> Array a
Attaches an element to the front of an array, creating a new array.

cons 1 [2, 3, 4] = [1, 2, 3, 4]
-- Note, the running time of this function is O(n).
```

**Naming**
I find some naming quite obscure fro someone with little knowledge of Lisp / new to the language etc., e.g. unless you *know* what `snoc` means *a priori*, is hard to find a function in Pursuit to simply:
>Append an element to the end of an array, creating a new array.

Is there any way this could be improved, perhaps just tags in search?