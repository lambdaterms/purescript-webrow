module WebRow.Mailer where

import Prelude

import Data.Symbol (SProxy(..))
import Data.Variant.Internal (FProxy)
import Run (Run)
import Run as Run
import WebRow.Types (Email)

data MailerF a
  = SendMail 
      { to ∷ Email
      , subject ∷ String
      , text ∷ String
      }
      (String → a)

derive instance functorMailerF ∷ Functor MailerF

type MAILER = FProxy MailerF

type MailerEff eff = ( mailer ∷ MAILER | eff )

_mailer = SProxy ∷ SProxy "mailer"

sendMail ∷
  ∀ eff
  . { to ∷ Email
    , subject ∷ String
    , text ∷ String
    }
  → Run ( mailer ∷ MAILER | eff ) String
sendMail msg = Run.lift _mailer (SendMail msg identity)