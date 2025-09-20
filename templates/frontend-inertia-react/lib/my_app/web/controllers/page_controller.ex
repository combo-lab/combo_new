defmodule MyApp.Web.PageController do
  use MyApp.Web, :controller

  def home(conn, _params) do
    conn
    |> render_inertia("Home")
  end
end
