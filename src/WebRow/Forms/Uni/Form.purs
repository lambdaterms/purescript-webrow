module WebRow.Forms.Uni.Form where

import Prelude
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)
import Polyform (Reporter)
import Polyform.Reporter (runReporter)
import WebRow.Forms.BuilderM (eval) as BuilderM
import WebRow.Forms.Payload (UrlDecoded)
import WebRow.Forms.Uni.Builder (Builder(..))

newtype Form m layout o
  = Form
  { default ∷ layout
  , reporter ∷ Reporter m layout UrlDecoded o
  }

build ∷ ∀ layout m o. Builder m layout UrlDecoded o → Form m layout o
build (Builder b) = Form (BuilderM.eval b)

default :: forall layout m o. Form m layout o -> layout
default (Form form) = _.default form

validate ∷
  ∀ layout m o.
  Functor m ⇒
  Form m layout o →
  UrlDecoded →
  m (Tuple (Maybe o) layout)
validate (Form { reporter }) i = runReporter reporter i
