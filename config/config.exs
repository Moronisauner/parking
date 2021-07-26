# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :parking,
  ecto_repos: [Parking.Repo]

# Configures the endpoint
config :parking, ParkingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w0f8q4UsthZTE/aMPxMRkEHya9LpWUSoexT+9/8UBZSPg5Wqkz3Sjnj/mMIVhCsq",
  render_errors: [view: ParkingWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Parking.PubSub,
  live_view: [signing_salt: "CHh9H/Iu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
