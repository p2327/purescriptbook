
### Spago repl

```
> "Hello, " <> "World!"
"Hello, World!"
```

```
> import Main
> diagonal 5.0 12.0

13.0
```

```
> flip (\n s -> show n <> s) "Ten" 10

"10Ten"
```

```
> :paste
… showFunc n s = show n <> s
… 
> showFunc 4 "Ten"
"4Ten"
> flip showFunc "Ten" 4
"4Ten"
```

### Types

Just like values are distinguished by their *types*, types are distinguished by their *kinds*.

The kind called **Type** represents the kind of all types which have values, like Number and String.

There are also kinds for *type constructors*. For example, the kind ```Type -> Type``` represents a function from types to types, just like ```List```.

```
> :kind Number
Type

> import Data.List
> :kind List
Type -> Type

> :kind List String
Type
```

### Test Early, Test Often

```
> import Data.AddressBook
> address = { street: "123 Fake St.", city: "Faketown", state: "CA" }
> showAddress address
"123 Fake St., Faketown, CA"

> entry = { firstName: "John", lastName: "Smith", address: address }
> showEntry entry
"Smith, John: 123 Fake St., Faketown, CA"
```

### Creating AddresBook

`insertEntry :: Entry -> AddressBook -> AddressBook` type signature says that `insertEntry` takes an Entry as its first argument, and an `AddressBook` as a second argument, and returns a *new* `AddressBook`.

To implement `insertEntry`, we can use the `Cons`function from `Data.List`. 

```
> import Data.List
> :type Cons

forall a. a -> List a -> List a
```

`Cons` type signature says that it takes a value of some type a, and a list of elements of type a, and returns a new list with entries of the same type. 

For our Entry type:

`Entry -> List Entry -> List Entry`

But List Entry is the same as AddressBook, so this is equivalent to

`Entry -> AddressBook -> AddressBook`

```
> abook = emptyBook
> :type abook
List                             
  { address :: { city :: String  
               , state :: String 
               , street :: String
               }                 
  , firstName :: String          
  , lastName :: String           
  }  

> insertEntry entry abook
({ address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" } : Nil)

> abook
Nil
```

But then I must create a new entry book everytime I enter a new entry...

```
> nbook = insertEntry entry abook
> nbook
({ address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" } : Nil)

> entry2 = { firstName: "Lorne", lastName: "Malvo", address: address }
> tbook = insertEntry entry2 nbook

> abook
Nil

> nbook
({ address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" } : Nil)

> tbook
({ address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "Lorne", lastName: "Malvo" } : { address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" } : Nil)
```

But then how do I create a new `AddressBook` withouth using `emptyBook`? 
```
> book = List entry
```
does not work...

So, maybe

```
> :paste
… mynewbook :: AddressBook
… mynewbook = insertEntry entry emptyBook
… 
> mynewbook
({ address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" } : Nil)
```

See reference on [data types](https://github.com/JordanMartinez/purescript-jordans-reference/blob/latestRelease/01-FP-Philosophical-Foundations/03-Data-Types.md)


*In order to abide by the principle of pure functions, FP Data Types tend to adhere to two principles:*

1. *Immutable - the data does not change once created. To modify the data, one must create a copy of the original that includes the update.*
2. *Persistent - Rather than creating the entire structure again when updating, an update should create a new 'version' of a data structure that includes the update*

```
{-
Given a linked-list type where
  "Nil" is a placeholder representing the end of the list
  "←" in "left ← right" is a pointer that points from the
      right element to the left element
  "=" in "list = x" binds the 'x' name to the 'list' value          -}
Nil ← 1 ← 2 ← 3 = x
                                                                    {-
To change x's `2` to `4`, we would create a new 'version' of 'x'
  that includes the unchanged tail (Nil ← 1)
  followed by the new update (← 4) and
  a copy of the rest of the list (← 3).                            -}
Nil ← 1 ← 2 ← 3 = x
      ↑
      4 ← 3 = y
```


### Curried functions

Functions in PureScript take exactly **one** argument. While it looks like the insertEntry function takes two arguments, it is in fact an example of a curried function.

The -> operator in the type of insertEntry associates to the right, which means that the compiler parses the type as

`Entry -> (AddressBook -> AddressBook)`

That is, insertEntry is a function which returns a function! It takes a single argument, an Entry, and returns a new function, which in turn takes a single AddressBook argument and returns a new AddressBook


Now consider the definition of insertEntry:

```
insertEntry :: Entry -> AddressBook -> AddressBook
insertEntry entry book = Cons entry book
```

If we explicitly parenthesize the right-hand side, we get

```
insertEntry entry book = (Cons entry) book
```

That is, `insertEntry entry` argument `entry` is just passed to the `Cons` functions, and both result in `book`

But if two functions have the same result for every input, **they are the same function**!
We can remove the argument book from both sides:

```
insertEntry :: Entry -> AddressBook -> AddressBook
insertEntry entry = Cons entry

-- By the same argument we can remove entry
insertEntry :: Entry -> AddressBook -> AddressBook
insertEntry = Cons
```

This process is called eta conversion, and can be used (along with some other techniques) to rewrite functions in point-free form, which means functions defined without reference to their arguments.
[Link](https://wiki.haskell.org/Eta_conversion)

[Problems with point-free](https://wiki.haskell.org/Pointfree)

### Querying the address book

We want to implement a function to look up a person by name and return the right entry, let's call is `findEntry`.

In order to do so, we will need to:

1. Filter the address book, keeping those entries with the correct first and last names
2. Return the head (i.e. first) element of the resulting list.

Let's look at `filter` and `head`:

```
$ spago repl

> import Data.List
> :type filter
forall a. (a -> Boolean) -> List a -> List a

> :type head
forall a. List a -> Maybe a
```

`filter` is a curried function of two arguments. Its first argument `(a -> Boolean)` is a function, which takes a list element and returns a Boolean value as a result. Its second argument `List a` is a list of elements, and the return value is another list.

`head` takes a list as its argument, and returns `Maybe a`. `Maybe a` represents an optional value of type a, and provides a type-safe alternative to using null to indicate a missing value.

The universally quantified types of filter and head can be specialized by the PureScript compiler, to the following types:
```
filter :: (Entry -> Boolean) -> AddressBook -> AddressBook

head :: AddressBook -> Maybe Entry
```

We can use the above to create a function that queries an address book using firstName and lastName.

Facts:
- We want to search for first and and last name; they are of type `String`
- We will need to pass these as arguments
- We will need a function of type `Entry -> Boolean` to pass to `filter`, as it takes a function as its first argument; let's call it `filterEntry`: it will take first name, last name and return bool
- The second argument of filter will be a list of elements, in our case `AddressBook`
- The result of `filter filterEntry AddressBook` will return a type `AddressBook` (here we simply substituted `filterEntry` to `(Entry -> Boolean)`)
- Passing the result of the above to the head function gives us the result of type `Maybe Entry`

Putting the above together results in the following type signature for our function:

```
filter :: String -> String -> AddressBook -> AddressBook

head :: AddressBook -> Maybe Entry
```

We can revisualise as

```
findEntry :: String -> String -> AddressBook -> Maybe Entry
```

In other words, `findEntry` is defined by doing `filter` and then `head`.

Passing a value into `filter` outputs a *intermediate value*, that value then gets passed into `head` which then produces the *output value*. [Reference](https://github.com/JordanMartinez/purescript-jordans-reference/blob/latestRelease/01-FP-Philosophical-Foundations/01-Composition-Everywhere.md)

And here's the definition of findEntry:

```
findEntry firstName lastName book = head $ filter filterEntry book
  where
    filterEntry :: Entry -> Boolean
    filterEntry entry = entry.firstName == firstName && entry.lastName == lastName
```

`filterEntry book` is (Entry -> Boolean) -> AddressBook
We then pass the resulting AddressBook to `head`.

firstName and lastName are arguments to filterEntry

In other words findEntry takes firstName and lastName, passes them to filterEntry, the result is filtered with book, and the result is passed to head.

Or actually

`head <<< filter filterEntry` returns Maybe Entry

`String String AddressBook` are the arguments of findEntry

```
> mynewbook = insertEntry entry emptyBook
> findEntry "John" "Smith" mynewbook
(Just { address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" })
```

### Final thoughts

This all works!
```
> import Data.AddressBook
> import Data.List
> address = { street: "123 Fake St.", city: "Faketown", state: "CA" }
> entry = { firstName: "John", lastName: "Smith", address: address }
> addressbook = insertEntry entry emptyBook
> findEntry "John" "Smith" addressbook
(Just { address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" })

> findEntryByStreet "123 Fake St." addressbook
(Just { address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" })
```