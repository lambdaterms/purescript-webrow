module WebRow.Crypto.String where

import Prelude

import Data.Argonaut (fromString, toString) as Argonaut
import Data.Either (Either, note)
import Effect.Exception (error) as Effect
import Global.Unsafe (unsafeStringify)
import WebRow.Crypto.Jwt (SignError, UnsignError(..))
import WebRow.Crypto.Jwt (sign, unsign) as Jwt
import WebRow.Crypto.Types (Secret)

sign
  ∷ Secret
  → String
  → Either SignError String
sign secret = Jwt.sign secret <<< Argonaut.fromString

unsign
  ∷ Secret
  → String
  → Either UnsignError String
unsign secret s
  = note (PossibleDecodingError (Effect.error (unsafeStringify s)))
  <<< Argonaut.toString
  <=< Jwt.unsign secret
  $ s

