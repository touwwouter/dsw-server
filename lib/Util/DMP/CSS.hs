module Util.DMP.CSS
       ( dmpCSS
       ) where

import Clay
import Prelude hiding (div, span)

-- | CSS style for generate HTML DMP
-- TODO: finish the style this is just dummy
dmpCSS = renderWith pretty [] $ do
  body ? margin (em 0.2) (em 0.2) (em 0.2) (em 0.2)
  headerCSS
  footerCSS
  mainCSS


headerCSS :: Css
headerCSS = do
  header ? borderBottom solid (px 3) (rgb 170 170 170)
  header |> h1 ? do
    fontSize (pct 200)
    margin (em 0.2) (em 0) (em 0.2) (em 0)
  header |> h1 |> div # ".km-name" ? do
    color (rgb 170 170 170)
    fontSize (pct 70)
    float floatRight
  header ? after & do
    content (stringContent "")
    display block
    clear both

footerCSS :: Css
footerCSS = do
  footer ? do
    padding (em 0.5) (em 0.5) (em 0.5) (em 0.5)
    textAlign center
    fontSize (pct 90)
  footer |> span # ".dsw-link" ? before &
    content (stringContent "⟨")
  footer |> span # ".dsw-link" ? after  &
    content (stringContent "⟩")

mainCSS :: Css
mainCSS = do
  section # ".chapter" ?
    borderBottom solid (px 2) (rgb 204 204 204)
  div # ".question" ? do
    borderLeft solid (px 2) orangered
    padding (em 0) (em 0.2) (em 0) (em 0.2)
    margin (em 0.1) (em 0) (em 0.5) (em 0.2)
  li # ".expert" |> span # ".email" ? before &
    content (stringContent "[")
  li # ".expert" |> span # ".email" ? after &
    content (stringContent "]")
  li # ".reference-dmpbook" |> span # ".dmpbook-chapter" ? before &
    content (stringContent "DMP Book chapter: ")
  div # ".answer-option" |> div # ".label" ? before &
    content (stringContent " » ")
  div # ".answer-items" |> div # ".answer-item" ? before &
    content (stringContent " » ")
  div # ".answer-simple" |> div # ".answer-string" ? before &
    content (stringContent " » ")
  div # ".answer-option" |> p # ".advice" ? before &
    content (stringContent " ⓘ ")
  div # ".answer-items" |> div # ".answer-item" |> span # ".title" ?
    display none
