module WebRow.Types where

import Type.Prelude (SProxy(..))
import Type.Row (type (+))
import WebRow.HTTP (HTTPExcept, Request)
import WebRow.Message (Message)
import WebRow.Routing (Routing)
import WebRow.Session (Session)

_webrow = SProxy ∷ SProxy "webrow"

type WebRow messages session route eff =
  ( HTTPExcept
  + Message messages
  + Request
  + Routing route
  + Session session
  + eff
  )
