port module Particles exposing (..)
import Html exposing (Html, Attribute, div, text, li, ul)
import Html.Keyed as Keyed
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Time exposing (Time)
import Random
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
maxParticles : Int
maxParticles = 50

type alias Position =
  { x: Int
  , y: Int
  }

type alias Particle =
  { class: String
  , initPosition: Position
  }

type alias Model =
  { particles: List Particle
  , currentSeed : Random.Seed
  }

model : (Model, Cmd Msg)
model =
  (Model [] (Random.initialSeed 3), Cmd.none)

-- UPDATE

type Msg
  = NewParticle Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewParticle time ->
      let
        (number, nextSeed) = Random.step (Random.int 1 60) model.currentSeed
      in
        ({model | particles = (add_particle(model.particles, number)), currentSeed = nextSeed }, Cmd.none)

add_particle (particles, number) =
  let
    particle_list = List.take maxParticles (List.map (\particle -> Particle "hexagon transluced" particle.initPosition) particles)
  in
    Particle "hexagon" (Position number 0) :: particle_list

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
        [ AnimationFrame.times NewParticle
        ]

-- VIEW

showParticle particle =
  let
    random_px =
      "px"
      |> String.append(toString(particle.initPosition.x))
    rotation =
      "deg)"
      |> String.append(toString(particle.initPosition.x * 20))
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
  ( toString(particle.initPosition.x), lazy showParticle(particle))

view : Model -> Html Msg
view model =
  div [ ] [
      Keyed.ul [ ] <|
        List.map showParticles model.particles
  ]
