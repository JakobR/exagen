{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module FormulaSpec (spec) where

import Test.Hspec
import Test.Hspec.Checkers
import Test.Hspec.Core.QuickCheck
import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes

import Logic.Propositional.Formula hiding (Prop(..))
import Problems.SAT


instance Eq a => EqProp (Formula a) where
  (=-=) = eq


numIff :: Formula a -> Int
numIff (Atomic _) = 0
numIff (Not f) = numIff f
numIff (And f g) = numIff f + numIff g
numIff (Or  f g) = numIff f + numIff g
numIff (Imp f g) = numIff f + numIff g
numIff (Iff f g) = 1 + numIff f + numIff g


spec :: Spec
spec = do
  modifyMaxSuccess (const 500) $ do
    describe "criteria" $ do
      it "different ways to count equivalences gives the same result" $
        property $ \(fm :: Formula Int) -> countSubformulas isIff fm == numIff fm

    describe "normalized formula" $ do
      it "is sorted" $ do
        property $ \(fm :: Formula Integer) -> let fm' = normalize fm
                                               in fm' == sortFlatFormula fm'

      -- NOTE: doesn't work atm, and I'm not sure if that's even possible
      it "discovers atom permutations (example 1)" $ do
        let f = Imp (And (Atomic Q) (Atomic P)) (Atomic Q)
        let g = Imp (And (Atomic P) (Atomic R)) (Atomic P)
        normalize f `shouldBe` normalize g

      it "discovers atom permutations" $ do
        property $ \(fm :: Formula Prop) (p :: PropPerm) ->
                     let fm' = fmap (applyPerm p) fm
                     in normalize fm == normalize fm'

    describe "Formula instances" $ do
      modifyMaxSuccess (const 10) $ do
        let trigger = undefined :: Formula (Int, Int, Int)
        testBatch $ functor trigger
        testBatch $ applicative trigger
        testBatch $ monad trigger
