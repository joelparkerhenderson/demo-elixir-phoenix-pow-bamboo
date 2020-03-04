defmodule DemoElixirPhoenixPowWeb.PowEmailConfirmation.MailerView do
  use DemoElixirPhoenixPowWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
