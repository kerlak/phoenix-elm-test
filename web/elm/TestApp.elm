port module TestApp exposing (..)
import Html exposing (Html, Attribute, div, text)
import Html.Attributes exposing (..)
import Time exposing (Time, second)
import Date exposing (Date)

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
port output : String -> Cmd msg
--

-- UPDATE

type Msg
  = Tick Time
  | GetMessage String
  | SendMessage Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (Model newTime model.goalTime model.message, Cmd.none)
    GetMessage message ->
      (Model model.currentTime model.goalTime message, Cmd.none)
    SendMessage message ->
      (Model model.currentTime model.goalTime model.message, output ("Hi! I'm Elm and i say tha it's: " ++ toString(message)))

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ Time.every second Tick
        , input GetMessage
        , Time.every second SendMessage
        ]

-- UTIL FUNCTIONS

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
myStyle =
  style
    [ ("width", "100%")
    , ("height", "100%")
    , ("font-family", "Arial")
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

    countdown =
      String.append (twoDigitString ndays)
      <| String.append " "
      <| String.append (twoDigitString nhours)
      <| String.append ":"
      <| String.append (twoDigitString nminutes)
      <| String.append ":"
      <| (twoDigitString nseconds)

  in
    div [ ] [
        div [ ] [ text countdown ]
      , div [ ] [ text model.message ]
    ]
