defmodule MyApp.Web.PageController do
  use MyApp.Web, :controller

  def home(conn, _params) do
    conn
    |> inertia_render("Home")
  end
end
