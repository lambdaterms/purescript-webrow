module WebRow.Testing.Templates where

import Prelude

import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Variant (Variant, case_, on)
import Text.Smolder.HTML (Html)
import Text.Smolder.HTML (div, form, h2, html, input) as M
import Text.Smolder.HTML.Attributes as A
import Text.Smolder.Markup ((!))
import Text.Smolder.Markup (text) as M
import Text.Smolder.Renderer.String as S
import Type.Row (type (+))
import WebRow.Forms (Layout, LayoutBase(..), TextInput) as Forms
import WebRow.Forms.Widgets (TextInputProps(..), _textInput)

html ∷ Html Unit → String
html body = S.render $ M.html ! A.lang "en" $ body

type FormLayout widgets = Forms.Layout (Forms.TextInput + widgets)

type RenderWidgets widgets = Variant widgets → Html Unit

formBody ∷ ∀ widgets. RenderWidgets widgets → FormLayout widgets → Html Unit
formBody renderExtra (Forms.Section { closed, errors, layout }) = do
  -- | TODO: Render form errors
  -- for_ errors case _ of
  --   Just (Left r) → M.p $ M.text (unsafeStringify r)
  --   otherwise → pure unit
  case closed of
    Just { title } → M.h2 $ M.text title
    Nothing → pure unit
  for_ layout (formBody renderExtra)

formBody renderExtra (Forms.Widget widget) = M.div $ do
  renderWidget widget
  where
  renderWidget =
    renderExtra
    # on _textInput \(TextInputProps { name, payload, type_ }) →
      -- | TODO: Render widget errors + value
      M.input ! A.type' type_ ! A.name name ! A.value "" -- (fromMaybe "" (value >>= Array.head))

form ∷ ∀ widgets. RenderWidgets widgets → FormLayout widgets → Html Unit
form renderExtra l = do
  M.form ! A.method "post" $ do
    formBody renderExtra l
    M.input ! A.type' "submit" ! A.value "submit"

form' ∷ FormLayout () → Html Unit
form' = form case_