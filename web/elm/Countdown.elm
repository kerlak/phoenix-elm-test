module Countdown exposing (..)
import Html exposing (Html, Attribute, div, text)
import Time exposing (Time)
import Date exposing (Date)
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
  }
goalTimeString : String
goalTimeString = "2017-04-21 14:00:00"
goalTime : Time
goalTime = createTime goalTimeString

model : (Model, Cmd Msg)
model =
  (Model 0 goalTime, Cmd.none)

-- UPDATE

type Msg
  = Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      ({ model | currentTime = newTime }, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ AnimationFrame.times Tick
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

createTime : String -> Time
createTime str =
  Date.fromString str
  |> Result.withDefault (Date.fromTime 0)
  |> Date.toTime

-- VIEW
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
    div [ ] [ text countdown ]
