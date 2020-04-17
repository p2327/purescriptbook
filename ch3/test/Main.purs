module Test.Main where

import Prelude

import Data.AddressBook 
import Data.List
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (log)
import Test.Assert (assert)


-- Test data
address :: Address
address = { street: "123 Fake St.", city: "Faketown", state: "CA" }

entry :: Entry
entry = { firstName: "John", lastName: "Smith", address: address }

addressbook :: AddressBook
addressbook = insertEntry entry emptyBook


-- Main
main :: Effect Unit
main = do
  assert (findEntry "John" "Smith" addressbook == Just entry)
  assert (findEntryByStreet "123 Fake St." addressbook == Just entry)
  assert (isInBook "John" "Smith" addressbook == true)
  -- log "🍝"
  -- log "You should add some tests."
