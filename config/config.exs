# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pet,
  ecto_repos: [Pet.Repo]

# Configures the endpoint
config :pet, Pet.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KiURZY5tzaJlzwPc6/Q0TAIJrWV4iLWAO8nIGa6kRjDnQ9HXY5Sq71ESTY056tef",
  render_errors: [view: Pet.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Pet.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
