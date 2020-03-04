# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :demo_elixir_phoenix_pow,
  ecto_repos: [DemoElixirPhoenixPow.Repo]

# Configures the endpoint
config :demo_elixir_phoenix_pow, DemoElixirPhoenixPowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YQoVWoOJt1gCR4mPwRE0SKc6KJ1Jb/ljt+U1InipxO61pD+UH+gkCUaYJPFZytzi",
  render_errors: [view: DemoElixirPhoenixPowWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DemoElixirPhoenixPow.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Pow authentication
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: DemoElixirPhoenixPow.PowMailer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

