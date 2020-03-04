defmodule DemoElixirPhoenixPowWeb.PageController do
  use DemoElixirPhoenixPowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
