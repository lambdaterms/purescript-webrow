module Test.WebRow.I18N where

import Prelude

import Data.Either (hush)
import Data.Generic.Rep (NoArguments(..))
import Data.Maybe (Maybe(..))
import Data.Variant (Variant)
import Routing.Duplex (RouteDuplex', parse, print, root)
import Routing.Duplex.Generic (noArgs)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Type.Prelude (SProxy(..))
import Type.Row (type (+))
import WebRow.I18N.ISO639.TwoLetter (LanguageNames)
import WebRow.I18N (languageCode, getLanguage)
import WebRow.I18N.Routing (duplex) as I18N.Routing

type Latine r = (la ∷ LanguageNames | r)
type Nepali r = (ne ∷ LanguageNames | r)
type Urdu r = (ur ∷ LanguageNames | r)

type Language = Variant (Latine + Nepali + Urdu ())

la ∷ Language
la = getLanguage (SProxy ∷ SProxy "la")

ne ∷ Language
ne = getLanguage (SProxy ∷ SProxy "ne")

ur ∷ Language
ur = getLanguage (SProxy ∷ SProxy "ur")

duplex ∷ RouteDuplex' { language ∷ Language, route ∷ NoArguments }
duplex = root $ I18N.Routing.duplex la noArgs

spec ∷ Spec Unit
spec = do
  describe "I18N" do
    describe "route duplex" do
      it "should print translated path" do
        let
          path = print duplex ({ language: ur, route: NoArguments })
        shouldEqual "/ur" path

      it "should print empty prefix for default lang" do
        let
          path = print duplex ({ language: la, route: NoArguments })
        shouldEqual "/" path

      it "should parse translated path" do
        let
          lang = parse duplex ("/ur")

        shouldEqual (hush lang <#> _.language >>> languageCode) (Just (languageCode ur))

      it "should parse default langauge path" do
        let
          lang = parse duplex ("/")

        shouldEqual (hush lang <#> _.language >>> languageCode) (Just (languageCode la))