#### Pattern matching

> The GCD of two or more non-zero integers is the largest positive integer that divides the numbers without a remainder.

Simple greatest common denominator `if..then..else` pattern
```
-- Euclidean algorithm implementation
gcd :: Int -> Int -> Int
gcd n 0 = n
gcd 0 m = m
gcd n m = if n > m
            then gcd (n - m) m
            else gcd n (m - n)
```

A function written using pattern matching works by pairing sets of conditions with their results. Each line is called an *alternative* or a *case*.
> The expressions on the left of the equals sign are called patterns,, and each case consists of one or more patterns, separated by spaces. Cases describe which conditions the arguments must satisfy before the expression on the right of the equals sign should be evaluated and returned. Each case is tried in order, and the first case whose patterns match their inputs determines the return value.

**Simple Patterns**
Type of patterns:
- Integer literals, which match something of type `Int`, only if the value matches exactly., e.g. `0`
- Variable patterns, which bind their argument to a name, e.g. `m`
- `Number`, `String`, `Char` and `Boolean` literals
- Wildcard patterns, indicated with an underscore `(_)`, which match any argument, and which do not bind any names.

**Other patterns**
- Array literals, e.g `[]` `[0, 1, a, b, _]`
- Records e.g. `showPerson { first: x, last: y } = y <> ", " <> x`
  -  They look just like record literals, but instead of values on the right of the colon, we specify a binder for each field.
  - They provide a good example of **row ploymorphism**:
```
> showPerson { first: x, last: y } = y <> ", " <> x

> :type showPerson
forall r. { first :: String, last :: String | r } -> String
```
`showPerson` signature with the `| r` (pipe r) reads "takes any record with first and last fields which are Strings and any other fields, and returns a String".

#### Guards

A guard is a boolean-valued expression which must be satisfied in addition to the constraints imposed by the patterns. 

Simple greatest common denominator using `guards`:
```
-- Euclidean algorithm implementation
gcd :: Int -> Int -> Int
gcd n 0 = n
gcd 0 m = m
gcd n m | n > m     = gcd (n - m) m -- the guard imposes an extra condition 
        | otherwise = gcd n (m - n) -- that must be satisfied in addition to the pattern
```

#### Row polymorphism
Row polymorphism is a feautre that allows to append additional fields to a record, as long
as they are of the same type.

In the Exercises `showPerson` is defined without a type signature. With row polymorphism we are still able to use `showPerson` for records that have additional field to the ones in the function definition, in the exampel below this is indicated by `| t6`.

For example, consider:
```
> import Exercises
> location = {street:"Long drive", city:"Los Angeles"}
> marl = {firstName: "Marl", lastName: "Smith", address: location}
> john = {firstName: "John", lastName: "Green", job:"Sales"}
> :type showPerson
forall t6.
  { first :: String
  , last :: String
  | t6
  }
  -> String

> showPerson {first: john.firstName, last: john.lastName}        
"Green, John"

> showPerson {first: "Marl", last: "Smith"}              
"Smith, Marl"

> showPerson' {first: "Marl", last: "Smith"}
"Marl, Smith"

> showPerson {first: "Marl", last: "Smith", address:"123 Street"} 
"Smith, Marl"
Error found:
in module $PSCI
at :1:13 - 1:65 (line 1, column 13 - line 1, column 65)

  Type of expression contains additional label address.

while checking that expression { first: "Marl"        
                               , last: "Smith"        
                               , address: "123 Street"
                               }
  has type { first :: String
           , last :: String 
           }
while applying a function showPerson'
  of type { first :: String
          , last :: String 
          }
          -> String        
  to argument { first: "Marl"        
              , last: "Smith"        
              , address: "123 Street"
              }
in value declaration it
```


#### Partial functions
Functions which return a value for any combination of inputs are called total functions, and functions which do not are called partial.

> If it is known that a function does not return a result for some valid set of inputs, it is usually better to return a value with type Maybe a for some a, using Nothing to indicate failure.

> The compiler will generate an error if it can detect that your function is not total due to an incomplete pattern match. The `unsafePartial` function can be used to silence these errors 

*PureScript keeps track of partial functions using the type system, and that we must explicitly tell the type checker when they are safe.*


#### Algebraic data types
An algebraic data type is introduced using the`data` keyword, followed by the name of the new type and any type arguments. The type's constructors are defined after the equals symbol, and are separated by pipe characters (|).

> The only way to consume a value of an algebraic data type is to use a pattern to match its constructor.

*Exercises repl*
```
> import Exercises
> import Data.Picture
> showPoint origin
"(0.0, 0.0)"

> showShape myCircle
"Circle [center: (0.0, 0.0), radius: 10.0]"

> myPoint = Point {x: 5.0, y: 12.0}
> showPoint myPoint
"(5.0, 12.0)"

> showShape conciseCircle
"Circle [center: (0.0, 0.0), radius: 10.0]"

> myLine = Line (Point {x: 2.0, y: 4.0}) (Point {x: 3.0, y:12.0})
"Line [start: (2.0, 4.0), end: (3.0, 12.0)]"

> showShape $ scaleUp myLine
"Line [start: (0.0, 0.0), end: (6.0, 24.0)]"

> showShape $ scaleShape myLine
"Line [start: (0.0, 0.0), end: (6.0, 24.0)]"

> myText = Text (Point {x: 2.0, y: 4.0}) ("Wish you were here")
> showText myText
(Just "Wish you were here")

> showText conciseCircle
Nothing
```

**Newtypes**
*Newtypes* are a special case of ADTs; they must define exactly one constructor, and that constructor must take exactly one argument.
> Newtype gives a new name to an existing type. In fact, the values of a newtype have the same runtime representation as the underlying type. They are, however, distinct from the point of view of the type system. This gives an extra layer of type safety.

```
> myPicture = [myLine, conciseCircle]
> showPicture myPicture
["Line [start: (2.0, 4.0), end: (3.0, 12.0)]","Circle [center: (0.0, 0.0), radius: 10.0]"]
```

