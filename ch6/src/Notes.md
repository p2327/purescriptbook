#### Type classes

Example, `Show`:

```
class Show a where
  show :: a -> String
```
`Show` is a type class which is parametrize by the type variable `a`.

`show` is a function defined by the type class `Show`.

Think of type classes as interfaces. For somethign to be of that type class it must implment the type property. **(More on thsi later)**

> A type class *instance* contains implementations of the functions defined in a type class.
For example, `Eq Boolean` is an instance of `Eq` type class.

Type classes are useful so that code can be written once and *parametrized* when needed, i.e. they solve code re-use problems. Think or Rust traits or Swift protocols. In other words, type classes abstract general concepts into an "interface" that can be implemented by various data types.

Examples:
- The `Eq` type class specifies a type signature for a function called `eq` and `notEq`, and laws for the two, but there are not any *derived functions* (functions that can be derived once one implements the type class) **Re exports?**
- The `Ord` type class is similar to Eq, but it does have *derived functions*.
- The `Functor` type class specifies the type signature for `map`. Once a type class has implemented map correctly, `Functor` provides the following derived functions:
  - void
  - voidRight
  - voidLeft
  - mapFlipped
  - flap

Exampl of an *instance* of `Show` type class that implements `show`.
```
instance showBoolean :: Show Boolean where
  show true = "true"
  show false = "false"
```
