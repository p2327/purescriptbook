module Data.AddressBook where

import Prelude

import Control.Plus (empty)
import Data.List (List(..), filter, head)
import Data.Maybe (Maybe)


-- Types
-- Records are similar to js objects (Python dicts?)
type Address = 
    { street :: String
    , city :: String
    , state :: String 
    }

type Entry = 
    { firstName :: String
    , lastName :: String
    , address :: Address
    }

type AddressBook = List Entry


-- Functions
showAddress :: Address -> String
showAddress a = a.street <> ", " <> a.city <> ", " <> a.state

showEntry :: Entry -> String
showEntry e = e.lastName <> ", " <> e.firstName <> ": " <> showAddress e.address

emptyBook :: AddressBook
emptyBook = empty

insertEntry :: Entry -> AddressBook -> AddressBook
insertEntry = Cons

findEntry :: String -> String -> AddressBook -> Maybe Entry
findEntry firstName lastName = head <<< filter filterEntry
    where -- function within a functions (?)
    filterEntry :: Entry -> Boolean
    filterEntry e = e.firstName == firstName && e.lastName == lastName