defmodule DemoElixirPhoenixPowWeb.PowResetPassword.MailerView do
  use DemoElixirPhoenixPowWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
