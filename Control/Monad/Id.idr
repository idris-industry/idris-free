module Control.Monad.Id

%default total
%access public export


data Id : (a : Type)-> Type where
  IdF : (x : a) -> Id a

implementation Functor Id where
  map f (IdF a) = IdF (f a)

implementation Applicative Id where
    pure a = IdF a
    (IdF f) <*> (IdF a) = IdF $ f a

implementation Monad Id where
  (IdF x) >>= f = f x

implementation (Show a)=>Show (Id a) where
  show (IdF a) = show a
