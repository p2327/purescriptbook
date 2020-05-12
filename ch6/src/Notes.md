#### Type classes

Example, `Show`:

```
class Show a where
  show :: a -> String
```
`Show` is a type class which is parametrize by the type variable `a`.

`show` is a function defined by the type class `Show`.

Think of type classes as interfaces. For something to be of that type class it must implement the type property. **(More on this later)**

> A type class *instance* contains implementations of the functions defined in a type class.
For example, `Eq Boolean` is an instance of `Eq` type class.

```
class Eq a where
  eq :: a -> a -> Boolean
```

```
instance eqBoolean :: Eq Boolean where
  eq = eqBooleanImpl

foreign import eqBooleanImpl :: Boolean -> Boolean -> Boolean
```
**Note** here foreign import denotes importing from the `.js` module in the source, here is the implementation, where `r1` and `r2` are the `Boolean -> Boolean` args:
```
"use strict";

var refEq = function (r1) {
  return function (r2) {
    return r1 === r2;
  };
};

exports.eqBooleanImpl = refEq;
```

**Type classes are useful so that code can be written once and *parametrized* when needed, i.e. they solve code re-use problems.** Think or Rust traits or Swift protocols. In other words, type classes abstract general concepts into an "interface" that can be implemented by various data types.

Examples:
- The `Eq` type class specifies a type signature for a function called `eq` and `notEq`, and laws for the two, but there are not any *derived functions* (functions that can be derived once one implements the type class) **Re exports?**
- The `Ord` type class is similar to Eq, but it does have *derived functions*.
- The `Functor` type class specifies the type signature for `map`. Once a type class has implemented map correctly, `Functor` provides the following derived functions:
  - void
  - voidRight
  - voidLeft
  - mapFlipped
  - flap

Example of an *instance* of `Show` type class that implements `show` for `Boolean` type.
```
instance showBoolean :: Show Boolean where
  show true = "true"
  show false = "false"
```

The `Show` implementation for `shape` from Chapter 5 is just `showShape`:
```
-- showInstance might be better named showShape but that's already taken
instance showInstance :: Show Shape where
    show = showShape
```
Ch5 repl:
```
> import Data.Show
> show myCircle
"Circle [center: (0.0, 0.0), radius: 10.0]"
```

#### Type classes examples

**Ord**

`Ord` extends the `Eq` type class and defines the `compare` function which can be used to compare two values *for types that support ordering*.
```
data Ordering = LT | EQ | GT
-- LT: less than
-- EQ: equal
-- GT: greater than

-- Here the <= stands for extends
class Eq a <= Ord a where
  -- Takes two same-type values and returns an Ordering
  compare :: a -> a -> Ordering
```
Repl test:
```
> compare "A" "Z"
LT
```

**Semigroups**
The `Semigroup` type class identifies those types which support an append operation to combine two values:
```
class Semigroup a where
  append :: a -> a -> a
```

- Strings and arrays form two semigroups under regular concatenation
- The `<>` operator is an alias for `append`

**Monoids**
The `monoid` type class extends the `Semigroup` type class with the concept of an empty value, called `mempty`:
```
class Semigroup m <= Monoid m where
  mempty :: m
```
A `Monoid` type class instance describes how to *accumulate* a result with that type. For example:
```
instance monoidString :: Monoid String where
  mempty = ""
```

For example we can write a function that concatenates an array of values using `foldl`, the function `append` and `mempty` as default value (b in the type signature, works as "accumulator"). Here f a is specialised as Array a.
```
> :type foldl
forall a b. (b -> a -> b) -> b -> Array a -> b

> foldl append mempty ["Hello", " ", "World"]
"Hello World"

> foldl append mempty [[1, 2, 3], [4, 5], [6]]
[1,2,3,4,5,6]
```
Equivalent to:
```
> import Data.Array
> concatMap (\a -> a) [[1, 2, 3], [4, 5], [6]]    
[1,2,3,4,5,6]
```

In other words, a `Monoid` is a `Semigroup` with an `empty` value

**Foldable and foldMap**

```
class Foldable f where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b
  foldl :: forall a b. (b -> a -> b) -> b -> f a -> b
  foldMap :: forall a m. Monoid m => (a -> m) -> f a -> m
```

Specialise `foldMap` for `Array`
```
forall a m. Monoid m => (a -> m) -> Array a -> m
```
This means we can choose any type `m` for our result type (as long as that type is an instance of the `Monoid` type class). In other words, if we can provide a function which turns our array elements into values in *that monoid* `m`, then we can return a single value accumulating over the array using the structure provided by that `Monoid`.

For example, `show` turns a type into `string`:
```
> import Data.Foldable

> foldMap show [1, 2, 3, 4, 5]
"12345"
```
> Here, we choose the monoid for strings, which concatenates strings together, and the show function which renders an `Int` as a `String`. Then, passing in an array of integers, we see that the results of showing each integer have been concatenated into a single String.

In general, Foldable captures the notion of an `ordered container`.

### Functor, and Type Class Laws
A `Functor` is any data type that defines how `map` applies to it. 
```
class Functor f where
  map :: forall a b. (a -> b) -> f a -> f b
```
For example, here's the implementation of `map` for `Maybe`:
```
instance functorMaybe :: Functor Maybe where
  map fn (Just x) = Just (fn x)
  map _  _        = Nothing
```
So we can do:
```
> import Data.Maybe           
> map (\n -> n + 3) (Just 5)
(Just 8)

> import Data.String (length)
> map length (Just "testing")
(Just 7)
```
>  The map function applies the function it is given to each element of a container, and builds a new container from the results, with the same shape as the original. 

Exercise
```
> import Exercises                           
> myI = Complex { real: 3.0, imaginary: 1.0 }
> show myI
"Real: 3.0 , Imaginary: 1.0i"

> anotherI = Complex { real: 3.0, imaginary: 2.0 }
> eq myI anotherI
false

> myI == anotherI
false
```

**Type class constraints**

Types of functions can be constrained by using type classes. Consider:
```
threeAreEqual :: forall a. Eq a => a -> a -> a -> Boolean
threeAreEqual a1 a2 a3 = a1 == a2 && a2 == a3
```
There is a **type class constraint** `Eq a`, separated from the rest of the type by a double arrow `=>`.

> This type says that we can call `threeAreEqual` with any choice of type a, as long as there is an Eq instance available for a in one of the imported modules.

Multiple constraints can be specified by using the => symbol multiple times, just like we specify curried functions of multiple arguments. For example:
```
showCompare :: forall a. Ord a => Show a => a -> a -> String
showCompare a1 a2 | a1 < a2 =
  show a1 <> " is less than " <> show a2
showCompare a1 a2 | a1 > a2 =
  show a1 <> " is greater than " <> show a2
showCompare a1 a2 =
  show a1 <> " is equal to " <> show a2
```

Exercises
```
> import Exercises
> someNonEmpty = NonEmpty 0 [1, 23, 44]
> anotherNonEmpty = NonEmpty 1 [1, 23, 44]
> show someNonEmpty
"0[1,23,44]"
> anotherNonEmpty == someNonEmpty 
false
