module WebRow.Forms.Widget where

import Prelude

import Data.Either (Either)
import Data.Foldable (class Foldable, foldr)
import Data.Functor.Variant (VariantF)
import Data.List (List(..), catMaybes, zip) as List
import Data.Map (fromFoldable) as Map
import Data.Maybe (Maybe)
import Data.Traversable (class Traversable, for, sequence)
import Polyform.Batteries.UrlEncoded (Query(..)) as UrlEncoded
import WebRow.Forms.BuilderM (BuilderM)
import WebRow.Forms.BuilderM (id) as BuilderM
import WebRow.Forms.Payload (Key, UrlDecoded, Value, lookup) as Payload

type Payload inputs
  = inputs (Maybe Payload.Value)

type Names inputs
  = inputs Payload.Key

type Widget widgets msg
  = VariantF widgets msg

type Initials msg inputs o
  = { payload ∷ Payload inputs
    , names ∷ Names inputs
    , result ∷ Maybe (Either (Array msg) o)
    }

type Constructor msg inputs widgets o
  = Initials msg inputs o → Widget widgets msg

names ∷
  ∀ inputs.
  Monoid (inputs Unit) ⇒
  Traversable inputs ⇒
  BuilderM (Names inputs)
names = for (mempty ∷ inputs Unit) (\_ → BuilderM.id)

-- | Extract payload from the query given a functor with names
payload ∷
  ∀ inputs.
  Functor inputs ⇒
  inputs Payload.Key →
  Payload.UrlDecoded →
  Payload inputs
payload inputs urlDecoded = map (flip Payload.lookup urlDecoded) inputs

dump ∷
  ∀ inputs.
  Foldable inputs ⇒
  Names inputs →
  Payload inputs →
  Payload.UrlDecoded
dump ns pl =
  UrlEncoded.Query
    <<< Map.fromFoldable
    -- | Drop empty values

    <<< List.catMaybes
    -- | Turn (Tuple k (Maybe v)) into (Maybe (Tuple k v))

    <<< map sequence
    $ List.zip
        (foldr List.Cons List.Nil ns)
        (foldr List.Cons List.Nil pl)
