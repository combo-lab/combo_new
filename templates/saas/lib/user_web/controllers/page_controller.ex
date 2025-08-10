defmodule DemoLT.UserWeb.PageController do
  use DemoLT.UserWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
