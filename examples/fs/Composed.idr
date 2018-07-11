module Main

import Fs
import Control.Monad.Free
import Data.Vect
import Data.Functor.Coproduct

%hide Prelude.File.readFile


data FileSystemF next
  = WriteFile FilePath String next
  | ReadFile FilePath (String -> next)

FileSystem : Type -> Type
FileSystem = Free FileSystemF

data ConsoleF next
  = ConsoleLog String next
  | ConsoleError String next

Console : Type -> Type
Console = Free ConsoleF


Functor FileSystemF where
  map f (WriteFile filePath contents next) = WriteFile filePath contents (f next)
  map f (ReadFile filePath fNext) = ReadFile filePath (f . fNext)

Functor ConsoleF where
  map f (ConsoleLog string next) = ConsoleLog string (f next)
  map f (ConsoleError string next) = ConsoleError string (f next)


AppF : Type -> Type
AppF = Coproduct FileSystemF ConsoleF

App : Type -> Type
App = Free AppF


-- | Some helper functions
liftFileSystem : FileSystemF a -> App a
liftFileSystem = liftFree . left

liftConsole : ConsoleF a -> App a
liftConsole = liftFree . right


-- | Helper functions for FileSystem
writeFile : FilePath -> Contents -> App Unit
writeFile filePath contents = liftFileSystem $ WriteFile filePath contents ()

readFile : FilePath -> App String
readFile filePath = liftFileSystem $ ReadFile filePath id


-- | Helper functions for Console
consoleLog : String -> App Unit
consoleLog string = liftConsole $ ConsoleLog string ()

consoleError : String -> App Unit
consoleError string = liftConsole $ ConsoleError string ()


-- | The FileSystem interpreter
interpretFs : FileSystemF a -> JS_IO a
interpretFs (WriteFile filePath contents next) = writeFileSync filePath contents *> pure next
interpretFs (ReadFile filePath fNext) = do
  contents <- readFileSync filePath
  pure (fNext contents)


-- | The Console interpreter
interpretConsole : ConsoleF a -> JS_IO a
interpretConsole (ConsoleLog string next) = putStrLn' string *> pure next
interpretConsole (ConsoleError string next) = putStrLn' string *> pure next


-- | The App interpreter that composes Console and FileSystem
interpretApp : AppF a -> JS_IO a
interpretApp (MkCoproduct (Left l)) = interpretFs l
interpretApp (MkCoproduct (Right r)) = interpretConsole r


-- | This program just reads foo.txt and prints its contents to stdout
catFoo : App Unit
catFoo = do
  contents <- readFile "foo.txt"
  consoleLog contents


main : JS_IO ()
main = foldFree interpretApp catFoo
