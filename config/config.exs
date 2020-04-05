# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# Configure general application
use Mix.Config

config :demo_elixir_phoenix_pow,
  ecto_repos: [DemoElixirPhoenixPow.Repo]

# Configure the endpoint.
config :demo_elixir_phoenix_pow, DemoElixirPhoenixPowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YQoVWoOJt1gCR4mPwRE0SKc6KJ1Jb/ljt+U1InipxO61pD+UH+gkCUaYJPFZytzi",
  render_errors: [view: DemoElixirPhoenixPowWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DemoElixirPhoenixPow.PubSub, adapter: Phoenix.PubSub.PG2]

# Configure Elixir Logger.
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix.
config :phoenix, :json_library, Jason

# Configure Pow authentication.
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: DemoElixirPhoenixPowWeb.PowMailer

# This section recommended by https://github.com/fewlinesco/bamboo_smtp 
config :demo_elixir_phoenix_pow, DemoElixirPhoenixPow.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"), # example: "smtp.example.com"
  hostname: System.get_env("SMTP_HOSTNAME"), # example: "my.example.com"
  port: System.get_env("SMTP_PORT"), # example: 1234
  username: System.get_env("SMTP_USERNAME"), # example: "alice@example.com"
  password: System.get_env("SMTP_PASSWORD"), # example: "mypassword"
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`
  retries:  1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

# Configure Pow mailer to use Bamboo and SMTP and env vars.
config :demo_elixir_phoenix_pow, DemoElixirPhoenixPowWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"), # example: "smtp.example.com"
  hostname: System.get_env("SMTP_HOSTNAME"), # example: "my.example.com"
  port: System.get_env("SMTP_PORT"), # example: 1234
  username: System.get_env("SMTP_USERNAME"), # example: "alice@example.com"
  password: System.get_env("SMTP_PASSWORD"), # example: "mypassword"
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

