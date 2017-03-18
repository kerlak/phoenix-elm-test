port module TestApp exposing (..)
import Html exposing (Html, Attribute, div, text, li)
import Html.Keyed as Keyed
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Time exposing (Time, second)
import Date exposing (Date)
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

type alias Model =
  { currentTime : Time
  , goalTime : Time
  , message : String
  , points : List Mouse.Position
  }

goalTimeString = "2017-04-21 14:00:00"
goalTime = createTime goalTimeString

model : (Model, Cmd Msg)
model =
  (Model 0 goalTime "no messages" [], Cmd.none)

--
port input : (Mouse.Position -> msg) -> Sub msg
port output : (String, Mouse.Position) -> Cmd msg
--

-- UPDATE

type Msg
  = Tick Time
  | GetMessage Mouse.Position
  | SendWave Mouse.Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (Model newTime model.goalTime model.message model.points, Cmd.none)
    GetMessage message ->
      (Model model.currentTime model.goalTime model.message (message :: model.points), Cmd.none)
    SendWave position ->
      (Model model.currentTime model.goalTime model.message model.points, output ("wave", position))

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ AnimationFrame.times Tick
        , input GetMessage
        , Mouse.clicks SendWave
        ]

-- UTIL FUNCTIONS
threeDigitString number =
  if number < 100 && number > 10 then
    toString number
    |> String.append "0"
  else if number < 10 then
    toString number
    |> String.append "00"
  else
    toString number

twoDigitString number =
  if number < 10 then
    toString number
    |> String.append "0"
  else
    toString number

createTime str =
  Date.fromString str
  |> Result.withDefault (Date.fromTime 0)
  |> Date.toTime

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

showPoint point =
  let
    circleRadius =
      10
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
        , ("width", circleRadiusPx)
        , ("height", circleRadiusPx)
        , ("border-radius", borderRadiusPx)
        , ("background-color", "#222")
        , ("top", top)
        , ("left", left)
        ]

  in
    div [ circleStyle ] [ ]

showPoints point =
    ( toString point.x, lazy showPoint point )

view : Model -> Html Msg
view model =
  let

    delta =
      model.goalTime - model.currentTime

    ndays =
      Time.inHours delta
      |> floor
      |> (flip (//)) 24

    nhours =
      Time.inHours delta
      |> floor
      |> (flip (-)) (ndays * 24)

    nminutes =
      Time.inMinutes delta
      |> floor
      |> (flip (-))(ndays * 24 * 60)
      |> (flip (-))(nhours * 60)

    nseconds =
      Time.inSeconds delta
      |> floor
      |> (flip (-))(ndays * 24 * 60 * 60)
      |> (flip (-))(nhours * 60 * 60)
      |> (flip (-))(nminutes * 60)

    nmillis =
      Time.inMilliseconds delta
      |> floor
      |> (flip (-))(ndays * 24 * 60 * 60 * 1000)
      |> (flip (-))(nhours * 60 * 60 * 1000)
      |> (flip (-))(nminutes * 60 * 1000)
      |> (flip (-))(nseconds * 1000)

    countdown =
      String.append (twoDigitString ndays)
      <| String.append "d "
      <| String.append (twoDigitString nhours)
      <| String.append "h "
      <| String.append (twoDigitString nminutes)
      <| String.append "m "
      <| String.append (twoDigitString nseconds)
      <| String.append "s "
      <| String.append (threeDigitString nmillis)
      <| "ms"

  in
    div [ ] [
        div [ vintageStyle ] [ text countdown ]
      , Keyed.ul [ ] <|
          List.map showPoints model.points
    ]
