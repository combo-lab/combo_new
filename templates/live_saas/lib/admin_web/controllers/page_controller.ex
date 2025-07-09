defmodule LiveSaaS.AdminWeb.PageController do
  use LiveSaaS.AdminWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
