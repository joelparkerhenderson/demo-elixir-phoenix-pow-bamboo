defmodule DemoElixirPhoenixPow.Repo do
  use Ecto.Repo,
    otp_app: :demo_elixir_phoenix_pow,
    adapter: Ecto.Adapters.Postgres
end
