# Demo of Elixir + Phoenix + Pow + Bamboo

Demonstrate:

* Elixir language
* Phoenix framework
* Pow authentication 
* Bamboo emailer

Contents:

* [How to create this demo](#how-to-create-this-demo)
  * [Preflight](#preflight)
  * [Create a typical Elixir Phoenix app](#create-a-typical-elixir-phoenix-app)
  * [Add Pow authentication](#add-pow-authentication)
  * [Add links to sign in and sign out](#add-links-to-sign-in-and-sign-out)
  * [Add Pow extensions for email](#add-pow-extensions-for-email)
  * [Mailer support](#mailer-support)
* [Learn more](#learn-more)


## How to create this demo


### Preflight

Verify you have Elixir 1.10 or higher:

```sh
elixir --version
Elixir 1.10.2 (compiled with Erlang/OTP 22)
```

Verify you have Mix 1.10 or higher

```sh
mix --version
Mix 1.10.2 (compiled with Erlang/OTP 22)
```


### Create a typical Elixir Phoenix app


Create a new Phoenix app:

```sh
mix phx.new demo_elixir_phoenix_pow
cd demo_elixir_phoenix_pow
```

Install dependencies:

```sh
mix deps.get
```

Create and migrate your database:

```sh
mix ecto.setup
```

Install Node.js dependencies:

```sh
cd assets
npm install
npm audit fix
cd ..
```

Start Phoenix endpoint:

```sh
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


### Update as needed

Check if any of dependencies are outdated and thus need updates:

```sh
mix hex.outdated
```

Update:

```sh
mix deps.update --all
```

If you get this kind of error:

```sh
(Mix) Can't continue due to errors on dependencies
```

Then try:

```sh
rm -rf deps _build
mix deps.update --all
```


### Add Pow authentication


Add Pow to your list of dependencies in mix.exs:

```elixir
defp deps do
  [
    # ...
    {:pow, "~> 1.0.18"}
  ]
end
```

Install:

```sh
mix pow.install
```

Append this to `config/config.exs` anywhere before `import_config ...`:


```elixir
# Configure Pow authentication
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo
```

Add `plug Plug.Session` and `plug Pow.Plug.Session` to `lib/demo_elixir_phoenix_pow_web/endpoint.ex`; if there is an existing `plug Plug.Session` secion then comment it out.

```elixir
defmodule DemoElixirPhoenixPowWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :demo_elixir_phoenix_pow

  # ...

  # plug Plug.Session,
  #   store: :cookie,
  #   key: "_demo_elixir_phoenix_pow_key",
  #   signing_salt: "vpEPCnKW"

  plug Plug.Session, @session_options
  plug Pow.Plug.Session, otp_app: :demo_elixir_phoenix_pow
  plug DemoElixirPhoenixPowWeb.Router
end
```

Update `lib/demo_elixir_phoenix_pow_web/router.ex` with the Pow routes:

```elixir
defmodule DemoElixirPhoenixPowWeb.Router do
  use DemoElixirPhoenixPowWeb, :router
  use Pow.Phoenix.Router

  # ... pipelines

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", DemoElixirPhoenixPowWeb do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end

end
```

Run:

```sh
mix ecto.setup
```

Visit http://localhost:4000/registration/new and create a new user.


### Add links to sign in and sign out

You can use `Pow.Plug.current_user/1` to fetch the current user from the connection. This can be used to show sign in or sign out links in your Phoenix template.

Edit `app.html.eex` and replace the default navigation with:

```eex
<nav role="navigation">
  <span><%= link "Home", to: "/" %></span>
  <%= if Pow.Plug.current_user(@conn) do %>
    <span><%= link "Sign out", to: Routes.pow_session_path(@conn, :delete), method: :delete %></span>
    <span><%= Pow.Plug.current_user(@conn).email %>
  <% else %>
    <span><%= link "Register", to: Routes.pow_registration_path(@conn, :new) %></span>
    <span><%= link "Sign in", to: Routes.pow_session_path(@conn, :new) %></span>
  <% end %>
</nav>
```

The current user can also be fetched by using the template assigns set in the configuration with `:current_user_assigns_key` (defaults to @current_user)`.


### Add Pow extensions for email


Install extension migrations:

```sh
mix pow.extension.ecto.gen.migrations --extension PowResetPassword --extension PowEmailConfirmation
mix ecto.migrate
```

Update `config/config.ex` with the keys for `:extensions` and `:controller_callbacks`:

```elixir
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks
```

Update `LIB_PATH/users/user.ex` with the extensions:

```elixir
defmodule DemoElixirPhoenixPow.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  # ...

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end
end
```

Update `WEB_PATH/router.ex` with extension routes:

```elixir
defmodule DemoElixirPhoenixPowWeb.Router do
  use DemoElixirPhoenixPowWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  # ...

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
  end

  # ...
end
```

Generate templates and views for extensions:

```sh
mix pow.extension.phoenix.gen.templates --extension PowResetPassword
mix pow.extension.phoenix.gen.templates --extension PowEmailConfirmation
```

You should see this message which is intentional:

```sh
Warning: No view or template files generated for PowEmailConfirmation as no templates has been defined for it.
```


### Add mailer support

Create a mailer mock module in `WEB_PATH/pow_mailer.ex`:

```elixir
defmodule DemoElixirPhoenixPowWeb.PowMailer do
  use Pow.Phoenix.Mailer
  require Logger

  def cast(%{user: user, subject: subject, text: text, html: html, assigns: _assigns}) do
    # Build email struct to be used in `process/1`

    %{to: user.email, subject: subject, text: text, html: html}
  end

  def process(email) do
    # Send email

    Logger.debug("Email sent: #{inspect email}")
  end
end
```

Update `config/config.ex` with `:mailer_backend` key:

```elixir
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: DemoElixirPhoenixPow.PowMailer
```


Phoenix doesn't ship with a mailer setup by default, so we modify `demo_elixir_phoenix_pow_web.ex` with a `:mailer_view` macro:

```elixir
defmodule DemoElixirPhoenixPow do
  # ...

  def mailer_view do
    quote do
      use Phoenix.View,
        root: "lib/demo_elixir_phoenix_pow/templates",
        namespace: DemoElixirPhoenixPow

      use Phoenix.HTML
    end
  end

  # ...

end
```

Generate view file and template file:

```sh
mix pow.extension.phoenix.mailer.gen.templates --extension PowResetPassword
mix pow.extension.phoenix.mailer.gen.templates --extension PowEmailConfirmation
```

Add `web_mailer_module: DemoElixirPhoenixPow` to the configuration, which enables Pow to use the views:

```elixir
config :demo_elixir_phoenix_pow, :pow,
  # ...
  web_mailer_module: DemoElixirPhoenixPowWeb
```

Visit http://localhost:4000/registration/new and you can now register then see a message "You'll need to confirm your e-mail before you can sign in. An e-mail confirmation link has been sent to you."


### Add Bamboo.Phoenix for emails


The Bamboo.Phoenix module renders emails with Phoenix layouts and views. See [HexDocs](https://hexdocs.pm/bamboo/Bamboo.Phoenix.html) and [Sending email with SMTP](https://www.phoenixframework.org/blog/sending-email-with-smtp).

Edit `mix.deps` to add:

Once we have a provider, we’ll need to add `bamboo` and `bamboo_smtp` as dependencies to our project. We’ll do that in the `deps/0` function in `mix.exs`. We will add AWS SES too.

```elixir
{:bamboo, "~> 0.7"},
{:bamboo_smtp, "~> 1.2.1"},
{:bamboo_ses_adapter, "~> 0.0.1"},
```

Update:

```sh
mix deps.get
```

TODO: do we edit `mix.exs` to add the `:bamboo` application?

```elixir
def application do
  [mod: {MyApp, []},
    applications: [
      :phoenix,
      :phoenix_html,
      :cowboy,
      :logger,
      :gettext,
      :phoenix_ecto,
      :postgrex,
      :bamboo
    ]
  ]
end
```

Edit `WEB_PATH/pow_mailer.ex` file like so:

```elixir
defmodule DemoElixirPhoenixPow.PowMailer do
  use Pow.Phoenix.Mailer
  use Bamboo.Mailer, otp_app: :my_app

  import Bamboo.Email

  @impl true
  def cast(%{user: user, subject: subject, text: text, html: html}) do
    Bamboo.Email.new_email(
      to: user.email,
      from: "myapp@example.com",
      subject: subject,
      html_body: html,
      text_body: text
    )
  end

  @impl true
  def process(email) do
    deliver_now(email)
  end
end
```

Edit `config.exs` to add:

```elixir
config :demo_elixir_phoenix_pow, DemoElixirPhoenixPow.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.domain",
  port: 1025,
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1
```

Create `lib/demo_elixir_phoenix_pow/mailer.ex` to enable the app to send emails:

```elixir
defmodule DemoElixirPhoenixPow.Mailer do
  use Bamboo.Mailer, otp_app: :demo_elixir_phoenix_pow
end
```

Verify `config/config.exs` has the Pow mailer:

```elixir
config :demo_elixir_phoenix_pow, :pow,
  user: DemoElixirPhoenixPow.Users.User,
  repo: DemoElixirPhoenixPow.Repo,
  mailer_backend: DemoElixirPhoenixPow.PowMailer
```


### Configure SMTP

Add our SMTP details to file `config/config.exs`. These will be provided by the SMTP service you use, such as Amazon Web Services (AWS) Simple Email Service (SES), or Fastmail.com, so look at your account service information.

Demos:

* [Demo AWS SES SMTP](https://github.com/joelparkerhenderson/demo_aws_ses_smtp)

* [Demo Fastmail SMTP](https://github.com/joelparkerhenderson/demo_fastmail_smtp)

Set environment variables for SMTP_USERNAME and SMTP_PASSWORD.

Example:

```sh
export SMTP_USERNAME="alice@example.com"
export SMTP_PASSWORD="secret"
```

These environment variables will be accessed by our file `config/config.exs`.


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
