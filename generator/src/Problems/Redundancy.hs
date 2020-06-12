{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

module Problems.Redundancy where

-- base
import Data.List
import Data.Maybe
import Data.String

-- containers
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map

-- filepath
import System.FilePath

-- lens
import Control.Lens

-- mtl
import Control.Monad.Reader

-- prettyprinter
import Data.Text.Prettyprint.Doc hiding (plural)

-- exagen
import Control.Monad.Choose
import Logic.FirstOrder
import Options (Options(..), RedOptions(..))
import Text.Show.Latex
import Util


main :: Options -> RedOptions -> IO ()
main Options{optNumExams,optOutputDir,optSeed} RedOptions = do

  infs <-
    let normalize x = (fst x :: Inference PredSym FnSym Variable)
    in distinctRandomChoices' optNumExams normalize genExamInference
       >>= either fail pure

  assertM (length infs == optNumExams)

  forM_ (zip infs [1..]) $ \((inf, theta), i :: Int) -> do

    let content = mconcat
          [ "% Random number generator seed: ", show optSeed, "\n"
          , "% Index: ", show i, "\n"
          , "% Substitution: ", unwords (lines (showPretty theta)), "\n"
          , showLatex inf, "\n"
          ]

    let sigcontent = formatSignature inf

    case optOutputDir of
      Nothing -> do
        putStrLn "\nInference: "
        printPretty inf
        putStr "\nusing the substitution "
        printPretty theta
        -- putStrLn $ "Signature: " <> sigcontent

      Just outputDir -> do
        examDir <- getExamDir outputDir i
        let file = examDir </> "red.tex"
        let sigfile = examDir </> "red.signature.tex"
        putStrLn $ "Writing file: " <> file
        writeFile file content
        putStrLn $ "Writing file: " <> sigfile
        writeFile sigfile sigcontent



formatSignature :: (HasSignature p fn v a, Ord v, ShowLatex p, ShowLatex fn, ShowLatex v) => a -> String
formatSignature x = formatSignature' (actualSignature x) (variablesOf x)

formatSignature' :: (ShowLatex p, ShowLatex fn, ShowLatex v) => Signature p fn -> Set v -> String
formatSignature' sig varsSet =
  formatDescription
  [ Descriptor (map showMath predicates) "predicate symbol"
  , Descriptor (map showMath functions) "function symbol"
  , Descriptor (map showMath constants) "constant"
  , Descriptor (map showMath vars) "variable"
  ]
  where
    showMath :: ShowLatex a => a -> String
    showMath x = "$" <> showLatex x <> "$"

    predicates = map symbol . Set.toAscList . sigPredicateSymbols $ sig
    functions = map symbol . filter ((>=1) . arity) . Set.toAscList . sigFunctionSymbols $ sig
    constants = map symbol . filter ((==0) . arity) . Set.toAscList . sigFunctionSymbols $ sig
    vars = Set.toAscList varsSet

data Descriptor = Descriptor
  { things :: [String]
  , what :: String
  }

formatDescription :: [Descriptor] -> String
formatDescription ds =
  case mapMaybe formatDescriptor ds of
    [] -> error "oh no"
    ds' -> oxfordComma ds' <> "."

formatDescriptor :: Descriptor -> Maybe String
formatDescriptor (Descriptor [] _) = Nothing
formatDescriptor (Descriptor [x] what) = Just $ x <> " is a " <> what
formatDescriptor (Descriptor xs what) = Just $ intercalate ", " xs <> " are " <> plural what

plural :: String -> String
plural what = what <> "s"

oxfordComma :: [String] -> String
oxfordComma [] = []
oxfordComma [x] = x
oxfordComma [x, y] = x <> " and " <> y
oxfordComma xs = intercalate ", " (init xs) <> ", and " <> last xs


-- | Generates an inference to be analysed in the exam problem.
--
-- Template: non-ground clause D
--           1 unit equality
--           1 non-equality literal
--
-- Generate: ground instance C of D
--           plus one extra literal (maybe of the non-equality literal)
--
--    C    D
--  ----------
--      ?
--
--  (note that the main premise is the left one!)
--
-- Questions:
-- a) Is the inference sound? prove using Sup+BR
-- b) Is the inference simplifying?
genExamInference
  :: MonadChoose m
  => m ( Inference PredSym FnSym Variable
       , Substitution FnSym Variable
       )
genExamInference = do
  -- NOTE: to have some symbol *not* appear in the output,
  --       we should adapt the generator to filter it out before.
  --       (with this small signature, the probability is very high that all symbols occur.)
  --       (easiest way to filter it out: just remove from signature...)
  let sigFns = Set.fromList @(Symbol FnSym)
        [ Symbol "f" 1
        , Symbol "g" 2
        , Symbol "h" 1
        , Symbol "a" 0
        , Symbol "b" 0
        , Symbol "c" 0
        , Symbol "d" 0
        ]
      sigPreds = Set.fromList @(Symbol PredSym)
        [ Symbol "P" 1
        ]
      sig = Signature { sigFunctionSymbols = sigFns
                      , sigPredicateSymbols = sigPreds
                      }
      vars = [minBound .. maxBound] :: [Variable]
      opts = GenOptions{ minDepth = 1
                       , maxDepth = 2
                       , sig = sig
                       , vars = vars
                       }

  let fnsWithArity2 = Set.map symbol $ Set.filter ((==2) . arity) sigFns

  -- Exactly one variable in each non-ground literal, and they should be different
  v1 <- choose vars
  v2 <- choose (filter (/= v1) vars)
  -- TODO: limit number of occurrences as well? (should be ==1 or >=2 for all exams)

  -- Generate literals
  -- l1: non-ground uninterpreted literal
  -- l2: ground uninterpreted literal
  -- l3: non-ground equality literal
  l1 <- mfilter (not . isGround) $ genUninterpretedLiteral opts{ vars = [v1] }
  -- l1 <- genUninterpretedLiteral opts{ vars = [v1] }
  -- guard (isNonGroundLiteral l1)
  l2 <- genUninterpretedLiteral opts{ vars = [] }
  l3 <- mfilter (not . isGround) $ genEqualityLiteral opts{ vars = [v2] }

  -- At least one function of arity two should appear
  let fns = functionSymbolsOf (Clause [l1, l2, l3])
  guard (not . Set.null $ Set.intersection fns fnsWithArity2)

  -- Generate ground substitution
  let thetaOpts = GenOptions{ minDepth = 0
                            , maxDepth = 1
                            , sig = sig
                            , vars = []
                            }
  theta <- genSubstitution thetaOpts vars

  -- Clauses
  -- c1: left premise, ground, redundant after inference, one additional irrelevant literal
  -- c2: right premise, non-ground
  -- c3: conclusion after applying subsumption resolution
  let c1 = Clause [applySubstitution theta (complementary l1), l2, applySubstitution theta l3]
  let c2 = Clause [l1, l3]
  let c3 = Clause [l2, applySubstitution theta l3]

  -- TODO
  -- * Idea: Control total number of symbols in term? [ not exactly, but in narrow range ]
  --         So if someone gets more unary functions, they will have more nesting instead.
  -- * Normalize final signature!
  --   (e.g. if variables are ["y", "z"], replace with some permutation of ["x","y"])
  let inf = Inference{ premises = [ c1, c2 ]
                     , conclusion = c3
                     }
  return (inf, theta)




-- | Concrete type for predicate symbols
newtype PredSym = PredSym String
  deriving newtype (Eq, Ord, Show, IsString, Pretty, ShowLatex)

-- | Concrete type for function symbols (including constant symbols)
newtype FnSym = FnSym String
  deriving newtype (Eq, Ord, Show, IsString, Pretty, ShowLatex)

-- | Concrete type for variables
data Variable = X | Y | Z
  deriving (Eq, Ord, Show, Enum, Bounded)

instance Pretty Variable where
  pretty X = "x"
  pretty Y = "y"
  pretty Z = "z"

instance ShowLatex Variable where
  showLatex X = "x"
  showLatex Y = "y"
  showLatex Z = "z"



-- TODO: We probably don't need this here
data KBOParams fn = KBOParams
  { precedence :: [fn]
  , weights :: Map fn Int
  , variableWeight :: Int
  }





data GenOptions p fn v = GenOptions
  { minDepth :: Int
  , maxDepth :: Int
  , sig :: Signature p fn
  , vars :: [v]
  }

data TermCtx = TermCtx
  { _depth :: Int   -- starts at 0 for the whole term, add 1 each time we go into a term's arguments
  }

depth :: Lens' TermCtx Int
depth = lens _depth (\x y -> x{ _depth = y })

genTerm :: forall m p fn v. MonadChoose m => GenOptions p fn v -> m (Term fn v)
genTerm GenOptions{minDepth,maxDepth,sig,vars} = runReaderT term initialCtx
  where
    initialCtx = TermCtx
      { _depth = 0
      }

    constants = filter ((==0) . arity) . Set.toList . sigFunctionSymbols $ sig
    functions = filter ((>0) . arity) . Set.toList . sigFunctionSymbols $ sig

    term :: ReaderT TermCtx m (Term fn v)
    term = do
      d <- view depth
      assertM (minDepth <= maxDepth)  -- not really necessary, we just don't return any terms in that case

      gen <- choose $ concat
             [ if d < maxDepth then [fnApp] else []
             , if d >= minDepth then [var, constApp] else []
             ]
      gen

    fnApp = do
      f <- choose functions
      args <- local (over depth (+1)) $ replicateM (arity f) term
      return (App (symbol f) args)

    constApp = do
      c <- choose constants
      return (App (symbol c) [])

    var = Var <$> choose vars


genLiteral' :: forall m p fn v. MonadChoose m => m (Atom p fn v) -> m (Literal p fn v)
genLiteral' genAtom = do
  atom <- genAtom
  pos <- choose [True, False]
  return (Literal pos atom)


genUninterpretedLiteral :: forall m p fn v. MonadChoose m => GenOptions p fn v -> m (Literal p fn v)
genUninterpretedLiteral opts = genLiteral' (genUninterpretedAtom opts)


genEqualityLiteral :: forall m p fn v. MonadChoose m => GenOptions p fn v -> m (Literal p fn v)
genEqualityLiteral opts = genLiteral' (genEqualityAtom opts)


genUninterpretedAtom :: forall m p fn v. MonadChoose m => GenOptions p fn v -> m (Atom p fn v)
genUninterpretedAtom opts@GenOptions{sig} = do
  let predicates = Set.toList (sigPredicateSymbols sig)
  p <- choose predicates
  args <- replicateM (arity p) (genTerm opts)
  return (Uninterpreted (symbol p) args)


genEqualityAtom :: forall m p fn v. MonadChoose m => GenOptions p fn v -> m (Atom p fn v)
genEqualityAtom opts = do
  t1 <- genTerm opts
  t2 <- genTerm opts
  return (Equality t1 t2)


genSubstitution
  :: forall m p fn v. (MonadChoose m, Ord v)
  => GenOptions p fn v   -- ^ options control the generation of terms in the range
  -> [v]   -- ^ domain of the generated substitution (will be identity on all other values)
  -> m (Substitution fn v)
genSubstitution opts domain = do
  pairs <- traverse (\v -> fmap (v,) (genTerm opts)) domain
  return $ Substitution (Map.fromList pairs)
