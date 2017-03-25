module Fps exposing (..)
import Html exposing (Html, div, text)
import Time exposing (Time)
import AnimationFrame exposing (..)

main : Program Never Model Msg
main =
  Html.program
    { init = model
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { fps : Time }

model : (Model, Cmd Msg)
model =
  (Model 0, Cmd.none)

-- UPDATE

type Msg
  = Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newDiff ->
      ({ model | fps = newDiff }, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ AnimationFrame.diffs Tick
        ]

-- VIEW
view : Model -> Html Msg
view model =
  let
    fps = floor(1 / Time.inSeconds(model.fps))
  in
    div [ ] [ text (toString(fps)), text " fps" ]
