module Main

import Fs
import Control.Monad.Free
import Data.Vect

anyVect : (n ** Vect n String)
anyVect = (3 ** ["Rod", "Jane", "Freddy"])


data FileSystemF next
  = WriteFile FilePath String next
  | ReadFile FilePath (String -> next)

FileSystem : Type -> Type
FileSystem = Free FileSystemF

Functor FileSystemF where
  map f (WriteFile filePath contents next) = WriteFile filePath contents (f next)
  map f (ReadFile filePath fNext) = ReadFile filePath (f . fNext)

writeFile : FilePath -> Contents -> FileSystem Unit
writeFile filePath contents = liftFree $ WriteFile filePath contents ()

readFile : FilePath -> FileSystem String
readFile filePath = liftFree $ ReadFile filePath id

echoHello : FileSystem Unit
echoHello = do
  writeFile "foo.txt" "hello, world!"
  contents <- readFile "foo.txt"
  writeFile "foo.txt" (contents <+> "!")

interpreter : FileSystemF a -> JS_IO a
interpreter (WriteFile filePath contents next) = writeFileSync filePath contents *> pure next
interpreter (ReadFile filePath fNext) = do
  contents <- readFileSync filePath
  pure (fNext contents)

main : JS_IO ()
main = foldFree interpreter echoHello
