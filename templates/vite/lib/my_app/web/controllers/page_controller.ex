defmodule MyApp.Web.PageController do
  use MyApp.Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
