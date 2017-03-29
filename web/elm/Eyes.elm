port module Eyes exposing (..)
import Html exposing (Html, Attribute, div, li, ul, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
  , state: Int
  , position: Mouse.Position
  }

type alias Model =
  { eyes : List Eye
  , showEmotions : Bool
  , lastClickPosition : Mouse.Position
  }

model : (Model, Cmd Msg)
model =
  (Model [] False (Mouse.Position 0 0), Cmd.none)

--
port init : (Eyes -> msg) -> Sub msg
port input : (Eye -> msg) -> Sub msg
port remove : (String -> msg) -> Sub msg
port output : (String, Mouse.Position) -> Cmd msg
port outputState : (String, Int) -> Cmd msg
--

-- UPDATE

type Msg
  = GetMessage Eye
  | SetEyes Eyes
  | RemoveEye String
  | SendWave Mouse.Position
  | SwitchEmotions Mouse.Position
  | SendEmotion Int

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
      let
        command =
          if model.showEmotions then
            Cmd.none
          else
            output ("walk", position)
      in
        (model, command)
    SwitchEmotions position ->
      ({ model | showEmotions = not model.showEmotions, lastClickPosition = position }, output ("walk", position))
    SendEmotion emotion ->
      (model, outputState("state", emotion))

set_eyes (all_eyes) =
  List.map (\eye -> new_eye(eye)) all_eyes.items

new_eye message =
  ( Eye message.id message.life message.skin message.state message.position )

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
    { eye | position = message.position, state = message.state }
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
        , Mouse.clicks SwitchEmotions
        ]

-- VIEW

showEye : Eye -> Html msg
showEye (eye) =
  let
    point = eye.position
    skin = eye.skin
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
      |> String.append(toString(point.y - circleRadius))
    left =
      "px"
      |> String.append(toString(point.x - circleRadius))

    circleStyle =
      style
        [ ("position", "absolute")
        , ("top", top)
        , ("left", left)
        ]
    stateClass =
      (toString(eye.state))
      |> String.append("comic_message selected image_")
  in
    div [ circleStyle, class "eyes", class ("type" ++ toString(skin)) ] [
      div [ class stateClass ] [ ]
    ]

view : Model -> Html Msg
view model =
  let
    left_px =
      "px"
      |> String.append(toString(model.lastClickPosition.x))

    top_px =
      "px"
      |> String.append(toString(model.lastClickPosition.y))

    indexStyle =
      style
        [ ("position", "absolute")
        , ("cursor", "pointer")
        , ("top", top_px)
        , ("left", left_px)
        , ("z-index", "1")
        ]
    emotion_list =
      if model.showEmotions then
        div [ indexStyle ] [
            div [ onClick (SendEmotion 1), class "comic_message emoticon_1" ] [ ]
          , div [ onClick (SendEmotion 2), class "comic_message emoticon_2" ] [ ]
          , div [ onClick (SendEmotion 3), class "comic_message emoticon_3" ] [ ]
          , div [ onClick (SendEmotion 4), class "comic_message emoticon_4" ] [ ]
          , div [ onClick (SendEmotion 5), class "comic_message emoticon_5" ] [ ]
          , div [ onClick (SendEmotion 6), class "comic_message emoticon_6" ] [ ]
          , div [ onClick (SendEmotion 7), class "comic_message emoticon_7" ] [ ]
          , div [ onClick (SendEmotion 8), class "comic_message emoticon_8" ] [ ]
        ]
      else
        div [ ] [ ]
  in
    div [ ] [
        emotion_list
      , ul [ ] <|
          List.map (\eye -> showEye(eye)) model.eyes

    ]
