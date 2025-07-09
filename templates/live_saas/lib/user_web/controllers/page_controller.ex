defmodule LiveSaaS.UserWeb.PageController do
  use LiveSaaS.UserWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
