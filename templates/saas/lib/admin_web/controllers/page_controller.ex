defmodule DemoLT.AdminWeb.PageController do
  use DemoLT.AdminWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
