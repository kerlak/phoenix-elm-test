port module Fire exposing (..)
import Html exposing (Html, Attribute, div, text, li, ul)
import Html.Attributes exposing (..)
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
max_particles : Int
max_particles = 20

speed : Float
speed = 160  -- pixels per second

particle_generation_time : Int  -- milliseconds
particle_generation_time = 30

type alias Vector =
  { x: Float
  , y: Float
  }

type alias Position =
  { x: Float  -- pixels
  , y: Float  -- pixels
  }

type alias Particle =
  { initial_position: Position
  , current_position: Position
  , goal_position: Position
  , percent: Float
  }

type alias Model =
  { particles: List Particle
  , last_particle_age: Int  -- milliseconds
  , current_seed : Random.Seed
  }

model : (Model, Cmd Msg)
model =
  (Model [] 0 (Random.initialSeed 3), Cmd.none)

-- UPDATE

type Msg
  = UpdateParticles Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateParticles diff ->
      update_particles(model, diff)

update_particles : (Model, Time) -> (Model, Cmd Msg)
update_particles (model, diff)=
  let
    (random_number, next_seed) = Random.step (Random.int 1 60) model.current_seed

    float_diff =
      Time.inMilliseconds diff
    new_age =
      float_diff
      |> floor
      |> (+) model.last_particle_age

    iterated_particles =
      iterate_particles(model.particles, float_diff)

    (added_particles, last_new_age) = add_particle(iterated_particles, new_age, random_number)
    particles = List.take max_particles added_particles

  in
    ({model | last_particle_age = last_new_age, particles = particles, current_seed = next_seed}, Cmd.none)

iterate_particles : (List Particle, Float) -> List Particle
iterate_particles (particles, diff) =
  List.map(\particle -> calculate_particle_position(particle, diff)) particles

calculate_particle_position : (Particle, Float) -> Particle
calculate_particle_position (particle, diff) =
  let
    new_position =
      calculate_position(
        particle.current_position
      , particle.goal_position
      , diff)
    new_percent =
      calculate_percent(
        particle.initial_position
      , particle.current_position
      , particle.goal_position)
  in
    ({particle | current_position = new_position, percent = new_percent})

calculate_percent (initial_position, current_position, goal_position) =
  let
    delta_current = (Position (current_position.x - initial_position.x) (current_position.y - initial_position.y))
    delta_goal = (Position (goal_position.x - initial_position.x) (goal_position.y - initial_position.y))
    mod_goal = sqrt((delta_goal.x ^ 2)+(delta_goal.y ^ 2))
    mod_current = sqrt((delta_current.x ^ 2)+(delta_current.y ^ 2))
    new_percent = mod_current / mod_goal
  in
    new_percent

calculate_position (current_position, goal_position, diff) =
  let
    delta_x = (goal_position.x - current_position.x)
    delta_y = (goal_position.y - current_position.y)
    vector_module = sqrt((delta_x ^ 2) + (delta_y ^ 2))
    (new_x, new_y) =
      if (vector_module == 0) then
        (goal_position.x, goal_position.y)
      else
        let
          delta_space = diff / 1000
          inc_x = ((delta_x / vector_module) * speed * delta_space)
          inc_y = ((delta_y / vector_module) * speed * delta_space)

          new_x =
            if (abs(delta_x) < abs(inc_x)) then
              goal_position.x
            else
              current_position.x + inc_x

          new_y =
            if (abs(delta_y) < abs(inc_y)) then
              goal_position.y
            else
              current_position.y + inc_y
        in
          (new_x, new_y)

  in
    (Position new_x new_y)

add_particle : (List Particle, Int, Int) -> (List Particle, Int)
add_particle (particles, last_age, random_number) =
  let
    last_new_age =
      if last_age >= particle_generation_time then
        0
      else
        last_age

    updated_particles =
      if last_age >= particle_generation_time then
        new_particle(random_number) :: particles
      else
        particles
  in
    (updated_particles, last_new_age)

new_particle : Int -> Particle
new_particle random_number =
  let
    initial_position = (Position (toFloat(random_number + 100)) 300)
    goal_position = (Position (toFloat(random_number + 100)) 120)
  in
    (Particle initial_position initial_position goal_position 0)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ AnimationFrame.diffs UpdateParticles ]

-- VIEW

type alias Color =
  { r: Int
  , g: Int
  , b: Int
  }

initial_color = (Color 253 191 18)
goal_color = (Color 255 0 0)

flame_size = 100

show_particle : Particle -> Html Msg
show_particle particle =
  let
    ease_out = particle.percent * (2 - particle.percent)

    x = floor(particle.current_position.x)
    y = floor(particle.current_position.y)

    top_px =
      "px"
      |> String.append(toString(particle.current_position.y))

    left_px =
      "px"
      |> String.append(toString(particle.current_position.x))

    diff_color =
      (Color
        (goal_color.r - initial_color.r)
        (goal_color.g - initial_color.g)
        (goal_color.b - initial_color.b)
      )

    percent_color =
      (Color
        (floor(ease_out * toFloat(diff_color.r)))
        (floor(ease_out * toFloat(diff_color.g)))
        (floor(ease_out * toFloat(diff_color.b)))
      )

    particle_color =
      (Color
        (initial_color.r + percent_color.r)
        (initial_color.g + percent_color.g)
        (initial_color.b + percent_color.b)
      )

    particle_color_string =
      ")"
      |> (String.append(toString(particle_color.b)))
      |> (String.append(","))
      |> (String.append(toString(particle_color.g)))
      |> (String.append(","))
      |> (String.append(toString(particle_color.r)))
      |> (String.append("rgb("))

    particle_width = flame_size * (1 - ease_out)
    particle_height = flame_size * (1 - ease_out)
    rotation =
      "deg)"
      |> String.append(toString(particle.initial_position.x * 20))
      |> String.append("rotate(")
    particle_style : Attribute msg
    particle_style =
      style[
          ("position", "absolute")
        , ("width", (String.append (toString(particle_width)) "px"))
        , ("height", (String.append (toString(particle_height)) "px"))
        , ("left", left_px)
        , ("top", top_px)
        , ("background-color", particle_color_string)
        , ("opacity", toString(0.7*(1 - ease_out)))
        , ("transform", rotation)
        ]
  in
    div [ particle_style ] [ ]

view : Model -> Html Msg
view model =
  div [ ] [
    ul [ ]
      <| List.map(\particle -> show_particle(particle)) model.particles
  ]
