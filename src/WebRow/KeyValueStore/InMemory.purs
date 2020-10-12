module WebRow.KeyValueStore.InMemory where

import Prelude
import Data.Map (Map)
import Data.Map (delete, insert, lookup) as Map
import Effect (Effect)
import Effect.Ref (Ref)
import Effect.Ref (modify, new, read) as Ref
import WebRow.KeyValueStore.Types (KeyValueStore, newKey)

type InMemory a
  = KeyValueStore Effect a

-- | TODO: Provide also efficient JS Map reference
-- | based implementation done through mutable
-- | reference.
new ∷ ∀ a. Effect (InMemory a)
new = forRef <$> Ref.new mempty

forRef ∷ ∀ a. Ref (Map String a) → InMemory a
forRef ref =
  let
    key = newKey ""

    delete k = (void $ Ref.modify (Map.delete k) ref) *> pure true

    get k = Ref.read ref >>= (Map.lookup k >>> pure)

    put k v = do
      void $ Ref.modify (Map.insert k v) ref
      pure true
  in
    { delete, get, new: key, put }
