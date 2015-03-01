module Main (main) where

import Data.Function
import Data.Maybe
import Math

import qualified Thermite as T
import qualified Thermite.Html as T
import qualified Thermite.Html.Elements as T
import qualified Thermite.Html.Attributes as A
import qualified Thermite.Action as T
import qualified Thermite.Events as T
import qualified Thermite.Types as T

data Action = UpdateHeight Number | UpdateMass Number

type State = { height :: Number
             , mass :: Number
             }

initialState :: State
initialState = { height: 175
               , mass: 75
               }

bmi :: Number -> Number -> Number
bmi heightCm mass = mass / (heightM `pow` 2)
  where
    heightM = heightCm / 100

foreign import getValue
  "function getValue(e) {\
  \  return parseInt(e.target.value);\
  \}" :: T.FormEvent -> Number

render :: T.Render State _ Action
render ctx st _ =
  T.div'
  [ result
  , textAndSlider "Height (in cm)" (\st -> st.height) (\v -> UpdateHeight v) 10 250
  , textAndSlider "Mass (in kg)" (\st -> st.mass) (\v -> UpdateMass v) 1 300
  ]
  where
  result :: T.Html _
  result =
    T.p'
      [ T.text " BMI: "
      , T.text $ show $ round $ bmi st.height st.mass
      ]

  textAndSlider :: String -> (State -> Number) -> (Number -> Action) -> Number -> Number -> T.Html _
  textAndSlider name value updateAction sMin sMax =
    T.p'
    [ T.text name
    , slider value updateAction sMin sMax
    , textInput value updateAction
    ]

  slider :: (State -> Number) -> (Number -> Action) -> Number -> Number -> T.Html _
  slider value updateAction sMin sMax =
    T.p'
      [ T.input
        [ A._type "range"
        , A.value (show $ value st)
        , A.min (show sMin)
        , A.max (show sMax)
        , T.onChange ctx (\e -> updateAction (getValue e))
        ] []
      ]

  textInput :: (State -> Number) -> (Number -> Action) -> T.Html _
  textInput value updateAction =
    T.p'
      [ T.input [ A.value (show $ value st)
                , T.onChange ctx (\e -> updateAction (getValue e))
                ] []
      ]

performAction :: T.PerformAction _ Action (T.Action _ State)
performAction _ (UpdateHeight n) = T.modifyState \o -> o { height = n }
performAction _ (UpdateMass n) = T.modifyState \o -> o { mass = n }

spec :: T.Spec _ State _ Action
spec = T.simpleSpec initialState performAction render

main = do
  let component = T.createClass spec
  T.render component {}
