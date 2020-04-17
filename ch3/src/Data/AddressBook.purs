module Data.AddressBook where

import Prelude

import Control.Plus (empty)
import Data.List (List(..), filter, head, null, nubBy)
import Data.Maybe (Maybe)
import Data.Newtype
-- import Type.Data.Boolean

-- Types
-- Records are similar to js objects (Python dicts?)
type Address = 
    { street :: String
    , city :: String
    , state :: String 
    }

-- Defines a type synonym 'Entry'
-- Equivalent to the type on the right of the equals
-- a record-type with three fields.

type Entry = 
    { firstName :: String
    , lastName :: String
    , address :: Address
    }

-- List is a type constructor
-- It takes a type argument a and constructs a new type List a
-- AddressBook is of type List Entry
type AddressBook = List Entry


-- Functions
showAddress :: Address -> String
showAddress a = a.street <> ", " <> 
                a.city <> ", " <> 
                a.state

showEntry :: Entry -> String
showEntry e = e.lastName <> ", " <> 
              e.firstName <> ": " <> 
              showAddress e.address

emptyBook :: AddressBook
emptyBook = empty

-- This function returns a new AddressBook
-- AddressBook is an example of immutable data structure
insertEntry :: Entry -> AddressBook -> AddressBook
insertEntry = Cons 
-- Here eta conversion is applied
-- insertEntry is just Cons on lists

findEntry :: String -> String -> AddressBook -> Maybe Entry
findEntry firstName lastName = head <<< filter filterEntry
    where -- function within a function (def, def?)
    filterEntry :: Entry -> Boolean
    filterEntry e = e.firstName == firstName && e.lastName == lastName


{- 
Ex 1

head :: AddressBook -> Maybe Entry

filter :: filterEntry -> AddressBook -> AddressBook

filterEntry :: Entry -> Boolean

Entry is a List element, Entry -> Boolean is the specialization of 
(a -> Boolean) which takes a list element (a) and returns
a Boolean


--- so

head <<< filter filterEntry returns Maybe Entry

String String AddressBook are the arguments of findEntry
-}


-- Ex 2
findEntryByStreet :: String -> AddressBook -> Maybe Entry
--findEntryByStreet streetName book = head $ filter filterEntry book
findEntryByStreet streetName = filter filterEntry >>> head
    where
    filterEntry :: Entry -> Boolean
    filterEntry e = e.address.street == streetName

{- 
see exercises
-}


-- Ex 3

-- working
isInBook :: String -> String -> AddressBook -> Boolean
isInBook firstName lastName book = not null $ filter filterEntry book
-- isInBook firstName lastName = not <<< null <<< filter filterEntry 
     where 
     filterEntry :: Entry -> Boolean
     filterEntry entry = entry.firstName == firstName && entry.lastName == lastName

{- 
for another day 
-- Let's try to be more type explicit
-- https://pursuit.purescript.org/packages/purescript-newtype/2.0.0/docs/Data.Newtype
--newtype Name = Name String
--newtype Surname = Surname String


isInBook :: Name -> Surname -> AddressBook -> Boolean
isInBook (Name n) (Surname s) b = not null $ filter filterEntry b
    where 
    filterEntry :: Entry -> Boolean
    filterEntry e = e.firstName == n && e.lastName == s

-- difference between type and newtype? 
-}


-- Ex 4
-- Takes an addressbook and, using the provided function 
-- (here, sameEntry) to determine equality, removes duplicates
-- > :type nubBy
--   forall a. (a -> a -> Boolean) -> List a -> List a
-- https://pursuit.purescript.org/packages/purescript-lists/5.4.1/docs/Data.List#v:nubBy
-- Returns a new book with duplicates removed
removeDuplicates :: AddressBook -> AddressBook
-- removeDuplicates book = nubBy isSameEntry book
removeDuplicates = nubBy isSameEntry
    where 
    isSameEntry :: Entry -> Entry -> Boolean
    isSameEntry x y = x.firstName == y.firstName && x.lastName == y.lastName