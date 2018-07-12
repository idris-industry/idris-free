module Control.Kan

-- left kan extension
data Lan : (Type -> Type) -> Type -> Type where
  FMap : (x -> a) -> g x -> Lan g a
