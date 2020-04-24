module FileOperations where

import Prelude

import Control.MonadZero (guard)
import Data.Path
import Data.Array
import Data.Array.Partial (head, tail) 
import Data.Maybe
import Data.Foldable (foldl, foldr)


allFiles :: Path -> Array Path
allFiles root = root : concatMap allFiles (ls root)


allFiles' :: Path -> Array Path
allFiles' file = file : do
  child <- ls file
  allFiles' child


onlyFiles :: Path -> Array Path
onlyFiles = filter isFile <<< allFiles
  where
  isFile = not <<< isDirectory


findLargestFile :: Path -> Maybe Path
findLargestFile = foldl largestFile Nothing <<< onlyFiles
  where
  largestFile (Just x) y = if (size x) > (size y) then Just x else Just y
  largestFile Nothing y = Just y


