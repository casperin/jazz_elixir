# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :jazz,
  ecto_repos: [Jazz.Repo]

# Configures the endpoint
config :jazz, JazzWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zpCdHC7wfW7KHp4qhMjaEGqWnrzo5u0wSMtlWRV8nb0IEcUc15w9rne0QreWefUk",
  render_errors: [view: JazzWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Jazz.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
