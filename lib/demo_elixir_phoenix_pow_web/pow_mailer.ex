defmodule DemoElixirPhoenixPowWeb.PowMailer do
  require Logger
  use Pow.Phoenix.Mailer
  use Bamboo.Mailer, otp_app: :demo_elixir_phoenix_pow

  import Bamboo.Email

  ##
  # This section is the Pow default mailer, 
  # without using the Bamboo mailer or Swoosh mailer.
  # We have commented it out because we are using Bamboo.
  ##

  # def cast(%{user: user, subject: subject, text: text, html: html, assigns: _assigns}) do
  #   # Build email struct to be used in `process/1`
  #
  #   %{to: user.email, subject: subject, text: text, html: html}
  # end
  #
  # def process(email) do
  #   # Send email
  #
  #   Logger.debug("Email sent: #{inspect email}")
  # end

  ##
  # This section is the Pow Bamboo code. 
  # This needs Bamboo to already be set up.
  # This uses our existing SMTP server at AWS.
  ##

  @impl true
  def cast(%{user: user, subject: subject, text: text, html: html}) do
    new_email(
      to: user.email,
      from: "xo@nonprofitnetworks.com",
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
