module Control.Kan

||| left kan extension
data Lan : (Type -> Type) -> Type -> Type where
  FMap : (x -> a) -> g x -> Lan g a

||| 'free' functor for any *->*
Functor (Lan f) where
  map func (FMap g y) = FMap (func . g) y
