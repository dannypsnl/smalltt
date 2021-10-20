{-# language UnboxedTuples #-}
{-# options_ghc -funbox-strict-fields #-}

module CoreTypes (
    Spine(..)
  , Closure(..)
  , Env(..)
  , Ty
  , VTy
  , Val(..)
  , Tm(..)
  , TopLevel(..)
  , topSpan
  , UnfoldHead
  , pattern UHTopVar
  , pattern UHSolved
  , Names(..)
  , showTm0
  , prettyTm
  ) where

import qualified Data.ByteString as B
import qualified EnvMask as EM
import qualified UIO

import Common
import Data.Bits
import EnvMask (EnvMask)

#include "deriveCanIO.h"

--------------------------------------------------------------------------------

data Spine
  = SId
  | SApp Spine Val Icit
  deriving Show

CAN_IO(Spine, LiftedRep, Spine, x, CoeSpine)

data Closure
  = Closure Env Tm
  deriving Show

CAN_IO2(Closure, TupleRep [ LiftedRep COMMA LiftedRep ], (# Env, Tm #), Closure x y, CoeClosure)

data Env
  = ENil
  | EDef Env ~Val
  deriving Show

type VTy = Val

data Val
  = VLocalVar Lvl Spine
  | VFlex MetaVar Spine
  | VUnfold UnfoldHead Spine ~Val
  | VLam Name Icit Closure
  | VPi Name Icit VTy Closure
  | VU
  | VIrrelevant
  deriving Show

CAN_IO(Val, LiftedRep, Val, x, CoeVal)

type Ty = Tm

data Tm
  = LocalVar Ix
  | TopVar Lvl ~Val
  | Let Span Tm Tm Tm
  | App Tm Tm Icit
  | Lam Name Icit Tm
  | InsertedMeta MetaVar EnvMask
  | Meta MetaVar
  | Pi Name Icit Ty Ty
  | Irrelevant
  | U
  deriving Show

CAN_IO(Tm, LiftedRep, Tm, x, CoeTm)

data TopLevel
  = Nil
  | Definition Span Tm Tm TopLevel
  deriving Show

CAN_IO(TopLevel, LiftedRep, TopLevel, x, CoeTopLevel)

topSpan :: Dbg => Ix -> TopLevel -> Span
topSpan 0 (Definition x _ _ _)   = x
topSpan x (Definition _ _ _ top) = topSpan (x - 1) top
topSpan _ _                      = impossible

topLen :: TopLevel -> Int
topLen = go 0 where
  go acc Nil = acc
  go acc (Definition _ _ _ t) = go (acc + 1) t

------------------------------------------------------------

-- data UnfoldHead = UHTopVar Lvl ~Val | UHSolved MetaVar
data UnfoldHead = UnfoldHead# Int ~Val

instance Eq UnfoldHead where
  UnfoldHead# x _ == UnfoldHead# x' _ = x == x'
  {-# inline (==) #-}

unpackUH# :: UnfoldHead -> (# (# Lvl, Val #) | MetaVar #)
unpackUH# (UnfoldHead# x v) = case x .&. 1 of
  0 -> (# (# Lvl (unsafeShiftR x 1), v #) | #)
  _ -> (# | MkMetaVar (unsafeShiftR x 1) #)
{-# inline unpackUH# #-}

pattern UHTopVar :: Lvl -> Val -> UnfoldHead
pattern UHTopVar x v <- (unpackUH# -> (# (# x, v #) | #)) where
  UHTopVar (Lvl x) ~v = UnfoldHead# (unsafeShiftL x 1) v

pattern UHSolved :: MetaVar -> UnfoldHead
pattern UHSolved x <- (unpackUH# -> (# | x #)) where
  UHSolved (MkMetaVar x) = UnfoldHead# (unsafeShiftL x 1 + 1) undefined
{-# complete UHTopVar, UHSolved #-}

instance Show UnfoldHead where
  show (UHTopVar x _) = "(TopVar " ++ show x ++ ")"
  show (UHSolved x  ) = "(Solved " ++ show x ++ ")"


--------------------------------------------------------------------------------

data Names
  = NNil Lvl TopLevel  -- ^ Number of top defs, top defs
  | NCons Names {-# unpack #-} Name

showLocal :: B.ByteString -> Names -> Ix -> String
showLocal src (NCons _ x)  0 = showName src x
showLocal src (NCons ns _) l = showLocal src ns (l - 1)
showLocal _   _            _ = impossible

getTop :: Names -> (Lvl, TopLevel)
getTop (NNil lvl top) = (lvl, top)
getTop (NCons ns _)   = getTop ns

showTop :: Dbg => B.ByteString -> TopLevel -> Ix -> String
showTop src top x = showSpan src (topSpan x top)


-- Pretty printing
--------------------------------------------------------------------------------

-- printing precedences
atomp = 3  :: Int -- U, var
appp  = 2  :: Int -- application
pip   = 1  :: Int -- pi
letp  = 0  :: Int -- let, lambda

-- Wrap in parens if expression precedence is lower than
-- enclosing expression precedence.
par :: Int -> Int -> ShowS -> ShowS
par p p' = showParen (p' < p)

prettyTm :: Int -> B.ByteString -> Names -> Tm -> ShowS
prettyTm prec src ns t = go prec ns t where

  eqName :: Name -> Name -> Bool
  eqName (NSpan x) (NSpan x') = eqSpan src x x'
  eqName NX        NX         = True
  eqName NEmpty    NEmpty     = True
  eqName _         _          = False

  count :: Names -> Name -> Int
  count ns n = go ns 0 where
    go NNil{}        acc = acc
    go (NCons ns n') acc
      | eqName n n' = go ns (acc + 1)
      | otherwise   = go ns acc

  counted :: String -> Int -> String
  counted x 0 = x
  counted x n = x ++ show n

  fresh :: Names -> Name -> (Name, String)
  fresh ns NEmpty    = (NEmpty, "_")
  fresh ns NX        = (NX, counted "x" (count ns NX))
  fresh ns (NSpan x) = (NSpan x, counted (showSpan src x) (count ns (NSpan x)))

  freshS ns x = fresh ns (NSpan x)

  local :: Names -> Ix -> String
  local (NCons ns n) 0 = snd (fresh ns n)
  local (NCons ns n) x = local ns (x - 1)
  local _            _ = impossible

  bracket :: ShowS -> ShowS
  bracket ss = ('{':).ss.('}':)

  piBind ns x Expl a = showParen True ((x++) . (" : "++) . go letp ns a)
  piBind ns x Impl a = bracket        ((x++) . (" : "++) . go letp ns a)

  lamBind x Impl = bracket (x++)
  lamBind x Expl = (x++)

  goMask :: Int -> Names -> MetaVar -> EM.EnvMask -> ShowS
  goMask p ns m mask = fst (go ns) where
    go :: Names -> (ShowS, Lvl)
    go (NNil _ _) =
      (((show m ++) . ('?':)), 0)
    go (NCons ns (fresh ns -> (n, x))) = case go ns of
      (s, l) -> EM.looked l mask
        (s, l + 1)
        (\_ -> ((par p appp $ s . (' ':) . (x++)), l + 1))

  goTop :: Lvl -> ShowS
  goTop x = case getTop ns of
    (len, top) -> UIO.run UIO.do
      debug ["pretty.goTop", show len, show x, show $ topLen top]
      UIO.pure (showTop src top (lvlToIx len x) ++)

  go :: Int -> Names -> Tm -> ShowS
  go p ns = \case
    LocalVar x   -> (local ns x++)
    App t u Expl -> par p appp $ go appp ns t . (' ':) . go atomp ns u
    App t u Impl -> par p appp $ go appp ns t . (' ':) . bracket (go letp ns u)

    Lam (fresh ns -> (n, x)) i t ->
      par p letp $ ("λ "++) . lamBind x i . goLam (NCons ns n) t where
        goLam ns (Lam (fresh ns -> (n, x)) i t) =
          (' ':) . lamBind x i . goLam (NCons ns n) t
        goLam ns t =
          (". "++) . go letp ns t

    U                   -> ("U"++)
    Pi NEmpty Expl a b  -> par p pip $ go appp ns a . (" → "++) . go pip (NCons ns NEmpty) b

    Pi (fresh ns -> (n, x)) i a b ->
      par p pip $ piBind ns x i a . goPi (NCons ns n) b where
        goPi ns (Pi (fresh ns -> (n, x)) i a b)
          | x /= "_" = piBind ns x i a . goPi (NCons ns n) b
        goPi ns b = (" → "++) . go pip ns b

    Let (freshS ns -> (n, x)) a t u ->
      par p letp $ ("let "++) . (x++) . (" : "++) . go letp ns a
      . ("\n  = "++) . go letp ns t . (";\n\n"++) . go letp (NCons ns n) u

    Meta m              -> (show m ++) . ('?':)
    InsertedMeta m mask -> goMask p ns m mask
    TopVar x _          -> goTop x
    Irrelevant          -> ("Irrelevant"++)

showTm0 :: B.ByteString -> Lvl -> TopLevel -> Tm -> String
showTm0 src len top t = prettyTm 0 src (NNil len top) t []
