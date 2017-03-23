port module TestApp exposing (..)
import Html exposing (Html, Attribute, div, text, li, ul)
import Html.Keyed as Keyed
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Time exposing (Time)
import Random
import Mouse exposing (position)
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
type alias Particles =
  { items: List Particle }

type alias Particle =
  { class: String
  , left: Int
  }

type alias Eyes =
  { items: List Eye }

type alias Eye =
  { id: String
  , life: Int
  , skin: Int
  , position: Mouse.Position
  }

type alias Model =
  { eyes : List Eye
  , particles: List Particle
  , currentSeed : Random.Seed
  }

model : (Model, Cmd Msg)
model =
  (Model [] [] (Random.initialSeed 3), Cmd.none)

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
  | NewParticle Time

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
    NewParticle time ->
      let
        (number, nextSeed) = Random.step (Random.int 1 60) model.currentSeed
      in
        ({model | particles = (add_particle(model.particles, number)), currentSeed = nextSeed }, Cmd.none)

add_particle (particles, number) =
  let
    particle_list = List.take 50 (List.map (\particle -> Particle "hexagon transluced" particle.left) particles)
  in
    Particle "hexagon" number :: particle_list

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
        , AnimationFrame.times NewParticle
        ]

-- UTIL FUNCTIONS
threeDigitString : Int -> String
threeDigitString number =
  if number < 100 && number > 10 then
    toString number
    |> String.append "0"
  else if number < 10 then
    toString number
    |> String.append "00"
  else
    toString number

twoDigitString : Int -> String
twoDigitString number =
  if number < 10 then
    toString number
    |> String.append "0"
  else
    toString number

-- VIEW
myStyle : Attribute msg
myStyle =
  style
    [ ("width", "100%")
    , ("height", "100%")
    , ("font-family", "Arial")
    ]

vintageStyle : Attribute msg
vintageStyle =
  style
    [ ("background", "linear-gradient(to bottom, #01075d 10%, #d1e2ff 50%, #030002 50%, #d401d9 70%, #fdeef1 90%")
    , ("-webkit-background-clip", "text")
    , ("-webkit-text-fill-color", "transparent")
    , ("font-size", "40px")
    , ("font-family", "Audiowide")
    ]
absoluteRight : Attribute msg
absoluteRight =
  style
    [ ("position", "absolute")
    , ("right", "10px")
    , ("top", "10px")
    , ("color", "#fff")
    , ("font-family", "Roboto")
    , ("width", "100vw")
    , ("text-align", "center")
    , ("line-height", "100vh")
    ]
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
        -- , ("width", circleRadiusPx)
        -- , ("height", circleRadiusPx)
        -- , ("border-radius", borderRadiusPx)
        -- , ("background-color", "#222")
        , ("top", top)
        , ("left", left)
        , ("transition", "top 1s ease-out, left 1s ease-out")
        ]

  in
    div [ circleStyle, class "eyes", class ("type" ++ toString(skin)) ] [ ]

showEyes eye =
    ( toString eye.id, lazy showEye(eye.position, eye.skin))

showParticle particle =
  let
    random_px =
      "px"
      |> String.append(toString(particle.left))
    rotation =
      "deg)"
      |> String.append(toString(particle.left * 20))
      |> String.append("rotate(")
    random_left_style : Attribute msg
    random_left_style =
      style[
          ("position", "absolute")
        , ("left", random_px)
        , ("transform", rotation)
        ]
  in
    div [ class particle.class, random_left_style ] [ ]

showParticles particle =
  ( toString(particle.left), lazy showParticle(particle))

view : Model -> Html Msg
view model =
  div [ ] [
      Keyed.ul [ ] <|
        List.map showEyes model.eyes
    , ul [ ]
        (List.map (\particle -> showParticle(particle)) model.particles)
  ]
