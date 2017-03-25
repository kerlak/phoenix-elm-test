port module Eyes exposing (..)
import Html exposing (Html, Attribute, div, li, ul)
import Html.Keyed as Keyed
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Mouse exposing (position)

main : Program Never Model Msg
main =
  Html.program
    { init = model
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Eyes =
  { items: List Eye }

type alias Eye =
  { id: String
  , life: Int
  , skin: Int
  , position: Mouse.Position
  }

type alias Model =
  { eyes : List Eye }

model : (Model, Cmd Msg)
model =
  (Model [], Cmd.none)

--
port init : (Eyes -> msg) -> Sub msg
port input : (Eye -> msg) -> Sub msg
port remove : (String -> msg) -> Sub msg
port output : (String, Mouse.Position) -> Cmd msg
--

-- UPDATE

type Msg
  = GetMessage Eye
  | SetEyes Eyes
  | RemoveEye String
  | SendWave Mouse.Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetEyes all_eyes ->
      ({ model | eyes = (set_eyes(all_eyes)) }, Cmd.none)
    RemoveEye id ->
      ({ model | eyes = (remove_eye(model, id)) }, Cmd.none)
    GetMessage message ->
      ({ model | eyes = (update_eyes(model, message)) }, Cmd.none)
    SendWave position ->
      (model, output ("walk", position))

set_eyes (all_eyes) =
  List.map (\eye -> new_eye(eye)) all_eyes.items

new_eye message =
  ( Eye message.id message.life message.skin message.position )

remove_eye (model, id) =
  List.filter (\eye -> (eye.id /= id)) model.eyes

update_eyes (model, message) =
  let
    is_new_eye = not (List.any (\eye -> (eye.id == message.id)) model.eyes)
  in
    if is_new_eye then
      add_eye(model, message)
    else
      List.map (\eye -> update_eye(eye, message)) model.eyes

add_eye (model, message) =
  let
    eye = new_eye message
  in
    eye :: model.eyes

update_eye (eye, message) =
  if eye.id == message.id then
    { eye | position = message.position }
  else
    eye
-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ input GetMessage
        , init SetEyes
        , remove RemoveEye
        , Mouse.moves SendWave
        ]

-- UTIL FUNCTIONS
twoDigitString : Int -> String
twoDigitString number =
  if number < 10 then
    toString number
    |> String.append "0"
  else
    toString number

-- VIEW

showEye (point, skin) =
  let
    circleRadius =
      5
    circleRadiusPx =
      "px"
      |> String.append(toString((circleRadius * 2)))
    borderRadiusPx =
      "px"
      |> String.append(toString((circleRadius * 2)))
    top =
      "px"
      |> String.append(twoDigitString (point.y - circleRadius))
    left =
      "px"
      |> String.append(twoDigitString (point.x - circleRadius))

    circleStyle =
      style
        [ ("position", "absolute")
        , ("top", top)
        , ("left", left)
        -- , ("transition", "top 1s ease-out, left 1s ease-out")
        ]

  in
    div [ circleStyle, class "eyes", class ("type" ++ toString(skin)) ] [ ]

showEyes eye =
    ( toString eye.id, lazy showEye(eye.position, eye.skin))

view : Model -> Html Msg
view model =
  div [ ] [
      Keyed.ul [ ] <|
        List.map showEyes model.eyes
  ]
