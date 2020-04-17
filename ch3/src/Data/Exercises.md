### Ex 1
```
head :: AddressBook -> Maybe Entry
filter :: filterEntry -> AddressBook -> AddressBook
filterEntry :: Entry -> Boolean
```
Entry is a List element, `Entry -> Boolean` is the specialization of `(a -> Boolean)` which takes a list element (a) and returns a Boolean.

Also, `head <<< filter filterEntry` returns `Maybe Entry`. `String`, `String`, `AddressBook` are the arguments of `findEntry`.

To see at work in the repl: 
```
> mynewbook = insertEntry entry emptyBook
> findEntry "John" "Smith" mynewbook
(Just { address: { city: "Faketown", state: "CA", street: "123 Fake St." }, firstName: "John", lastName: "Smith" })
```

### Ex 2
```
findEntryByStreet :: String -> AddressBook -> Maybe Entry
findEntryByStreet streetName book = head (filter filterEntry book)
    where
    filterEntry :: Entry -> Boolean
    filterEntry e = e.address.street == streetName
```

#### Infix function application
The `findEntryByStreet` function takes a `streeName` and a `book`,
applies `filterEntry` to the entry(ies) in the book (an AddressBook type, 
so a List of entries), returning True if `entry.address.streetName` (an element of book) 
equals the passed streetName. `filter` takes filterEntry and book as arguments 
and returns the filtered AddressBook. tThe returned value is passed to head which 
returns the first entry or nothing, if no entry is found.

The function in brackets is evaluated first, so we cna write:
`findEntryByStreet streetName book = head (filter filterEntry book)`
Using $ means 'apply' (is an alias), we can rewrite the above as:
`findEntryByStreet streetName book = head $ filter filterEntry book`
That is to say, apply left of $ (head) to the result of the function at
the right of $.


#### Function composition
Using (backward) composition we can rewrite the above as:
`findEntryByStreet streetName book = (head <<< filter filterEntry) book`
And, by applying eta conversion:
`findEntryByStreet streetName = head <<< filter filterEntry`
Forward composition is also valid:
`findEntryByStreet streetName = filter filterEntry >>> head`

We can use the composition operators since `book` is passed to 
the *composition* of `filter filterEntry` and `head`.

### Ex 3
```
isInBook :: String -> String -> AddressBook -> Boolean
isInBook firstName lastName book = not null $ filter filterEntry book
-- isInBook firstName lastName = not <<< null <<< filter filterEntry 
    where 
    filterEntry :: Entry -> Boolean
    filterEntry entry = entry.firstName == firstName && entry.lastName == lastName
```

### Ex 4
```
removeDuplicates :: AddressBook -> AddressBook
-- removeDuplicates book = nubBy isSameEntry book
removeDuplicates = nubBy sameEntry
    where 
    isSameEntry :: Entry -> Entry -> Boolean
    isSameEntry x y = x.firstName == y.firstName && x.lastName == y.lastName
```

Here we use nubBy to remove duplicates from an AddressBook type.
For each element a of address book, nubBy determines truthy-ness or falsey-ness by the function that's passed to it (sameEntry)


