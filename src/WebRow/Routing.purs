module WebRow.Routing
  ( module Exports
  , Routing
  , ROUTING
  , Routing'
  , context
  , printRoute
  , printFullRoute
  , redirect
  , route
  , _routing
  , runRouting
  , toFullUrl
  , url
  ) where

import Prelude

import Data.Array (singleton) as Array
import Data.Either (Either(..))
import Data.Lazy (defer) as L
import Data.Map (fromFoldableWith) as Map
import Data.String (Pattern(..), Replacement(..), replaceAll) as String
import Data.Variant (SProxy(..), Variant)
import HTTPure.Headers (empty) as HTTPure.Headers
import HTTPure.Request (Request) as HTTPure
import Polyform.Batteries.UrlEncoded (Query(..))
import Routing.Duplex (RouteDuplex', print) as D
import Routing.Duplex (RouteDuplex(..), RouteDuplex')
import Routing.Duplex.Parser (RouteError, RouteResult(..), parsePath, runRouteParser) as D
import Run (Run)
import Run.Reader (READER, askAt)
import Type.Row (type (+))
import WebRow.Contrib.Run.Reader (runReaders)
import WebRow.HTTP (HTTPExcept)
import WebRow.HTTP (redirect) as HTTP.Response
import WebRow.HTTP.Request (Request)
import WebRow.HTTP.Response.Except (notFound)
import WebRow.HTTP.Response.Types (Body(..))
import WebRow.Routing.Types (Context, Domain, FullUrl(..), RelativeUrl(..), fromRelativeUrl)
import WebRow.Routing.Types (Context, Domain, FullUrl(..), RelativeUrl(..), fromRelativeUrl, fromFullUrl) as Exports

_routing = SProxy ∷ SProxy "routing"

-- | TODO:
-- | Do we want to use custom effect here like
-- |
-- | `data RoutingF = PrintRouteF ..  | PrintFullRouteF ... | RedirectF ...
-- |
-- | Then we can abstract over i18n and simple routes in generic applets.
type ROUTING route
  = READER (Context route)

type Routing route eff
  = ( routing ∷ ROUTING route | eff )

type Routing' routes eff
  = Routing (Variant routes) eff

printRoute ∷ ∀ v eff. v → Run ( routing ∷ ROUTING v | eff ) RelativeUrl
printRoute v = map RelativeUrl $ askAt _routing <#> _.routeDuplex <#> flip D.print v

printFullRoute ∷ ∀ v eff. v → Run ( routing ∷ ROUTING v | eff ) FullUrl
printFullRoute v = printRoute v >>= toFullUrl

toFullUrl ∷ ∀ v eff. RelativeUrl → Run ( routing ∷ ROUTING v | eff ) FullUrl
toFullUrl (RelativeUrl str) = map FullUrl $ (<>) <$> (askAt _routing <#> _.domain) <@> str

context ∷ ∀ v. Domain → D.RouteDuplex' v → String → Either D.RouteError (Context v)
context domain routeDuplex@(RouteDuplex _ dec) = go
  where
  replacePlus = String.replaceAll (String.Pattern "+") (String.Replacement " ")

  go rawUrl =
    let
      routeState@{ hash, params } = D.parsePath (replacePlus rawUrl)

      -- | TODO: Do we need this `query` value from the Duplex side?
      -- | It seems that we want to keep it here so we can be
      -- | consistent on the frontend.
      -- | `Query` is provided is separately by `WebRow.HTTP.Request`
      -- | where it is really expected.
      query =
        L.defer \_ →
          Query
            <<< Map.fromFoldableWith append
            <<< map (map Array.singleton)
            $ params

      -- | TODO:
      -- | * drop query (raw contains this info)
      -- | * move `raw` to `raw.parts`
      -- | * move `url` to `raw.fullPath`
      ctx =
        { domain
        -- | Drop `query` and provide combinator which builds it
        , query
        , raw: routeState
        , route: _
        , routeDuplex
        , url: RelativeUrl rawUrl
        }
    in
      ctx
        <$> case D.runRouteParser routeState dec of
            D.Fail err → Left err
            D.Success _ res → Right res

runRouting ∷
  ∀ eff route.
  Domain →
  RouteDuplex' route →
  HTTPure.Request →
  Run (HTTPExcept + Request + Routing route + eff)
    ~> Run (HTTPExcept + eff)
runRouting domain routeDuplex request action = do
  case context domain routeDuplex request.url of
    Right routing → runReaders { request, routing } action
    Left e → do
      notFound HTTPure.Headers.empty (BodyString "")

route ∷ ∀ eff route. Run (Routing route + eff) route
route = askAt _routing <#> _.route

url ∷ ∀ eff route. Run (Routing route + eff) RelativeUrl
url = askAt _routing <#> _.url

-- hash ∷ ∀ eff route. Run (Routing route + eff) String
-- hash 
-- 
redirect ∷
  ∀ a eff route.
  route →
  Run
    ( HTTPExcept
        + Routing route
        + eff
    )
    a
redirect r = printRoute r >>= fromRelativeUrl >>> HTTP.Response.redirect
