module Fs

%access public export

%inline
jscall : (fname : String) -> (ty : Type) ->
          {auto fty : FTy FFI_JS [] ty} -> ty
jscall fname ty = foreign FFI_JS fname ty

FsModule : Type
FsModule = Ptr

FilePath : Type
FilePath = String

Contents : Type
Contents = String

fsModule : JS_IO FsModule
fsModule = jscall "require('fs')" (JS_IO FsModule)

readFileSync : FilePath -> JS_IO String
readFileSync filename = do
  fsModule' <- fsModule
  jscall "%0.readFileSync(%1, 'utf8')" (FsModule -> String -> JS_IO String) fsModule' filename

writeFileSync : FilePath -> Contents -> JS_IO ()
writeFileSync filename contents = do
  fsModule' <- fsModule
  jscall "%0.writeFileSync(%1, %2, 'utf8')" (FsModule -> String -> String -> JS_IO ()) fsModule' filename contents
