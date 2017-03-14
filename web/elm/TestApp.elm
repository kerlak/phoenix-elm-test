port module TestApp exposing (..)
import Html exposing (Html, Attribute, div, text)
import Html.Attributes exposing (..)
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
  }

goalTimeString = "2017-04-21 14:00:00"
goalTime = createTime goalTimeString

model : (Model, Cmd Msg)
model =
  (Model 0 goalTime "no message yet", Cmd.none)

--
port input : (String -> msg) -> Sub msg
port output : (String, Mouse.Position) -> Cmd msg
--

-- UPDATE

type Msg
  = Tick Time
  | GetMessage String
  | SendWave Mouse.Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (Model newTime model.goalTime model.message, Cmd.none)
    GetMessage message ->
      (Model model.currentTime model.goalTime message, Cmd.none)
    SendWave position ->
      (Model model.currentTime model.goalTime model.message, output ("wave", position))

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

circleStyle : Attribute msg
circleStyle =
  style
    [ ("position", "absolute")
    , ("width", "20px")
    , ("height", "20px")
    , ("border-radius", "10px")
    , ("background-color", "#222")
    ]

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
      --   div [ vintageStyle ] [ text countdown ]
      -- , div [ ] [ text model.message ]
       div [ circleStyle ] [ ]
    ]
