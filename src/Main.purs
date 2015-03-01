module Main (main) where

import Data.Function
import Data.Maybe

import qualified Thermite as T
import qualified Thermite.Html as T
import qualified Thermite.Html.Elements as T
import qualified Thermite.Html.Attributes as A
import qualified Thermite.Action as T
import qualified Thermite.Events as T
import qualified Thermite.Types as T

data Action = Increment | Decrement | Input Number

type State = { counter :: Number
             , mass :: Number
             , height :: Number
             }

initialState :: State
initialState = { counter: 0
               , mass: 75
               , height: 175
               }

bmi :: Number -> Number -> Number
bmi mass height = mass / (height * height)

foreign import getValue
  "function getValue(e) {\
  \  return parseInt(e.target.value);\
  \}" :: T.FormEvent -> Number

render :: T.Render State _ Action
render ctx s _ = T.div' [counter, textInput, slider, buttons]
  where
  counter :: T.Html _
  counter = 
    T.p'
      [ T.text "Value: "
      , T.text $ show s.counter
      ]

  slider :: T.Html _
  slider =
    T.p'
      [ T.input
        [ A._type "range"
        , T.onChange ctx (\e -> Input (getValue e)) ]
        [ T.text "Range" ]
      ]

  textInput :: T.Html _
  textInput =
    T.p'
      [ T.input [ A.value (show s.counter)
                , T.onChange ctx (\e -> Input (getValue e))
                ] []
      ]

  buttons :: T.Html _
  buttons = 
    T.p'
      [ T.button [ T.onClick ctx (\_ -> Increment) ] 
                 [ T.text "Increment" ]
      , T.button [ T.onClick ctx (\_ -> Decrement) ] 
                 [ T.text "Decrement" ]
      ]

performAction :: T.PerformAction _ Action (T.Action _ State) 
performAction _ Increment = T.modifyState \o -> o { counter = o.counter + 1 }
performAction _ Decrement = T.modifyState \o -> o { counter = o.counter - 1 }
performAction _ (Input s) = T.modifyState \o -> o { counter = s }

spec :: T.Spec _ State _ Action
spec = T.simpleSpec initialState performAction render
         # T.componentWillMount Increment

main = do
  let component = T.createClass spec
  T.render component {}
