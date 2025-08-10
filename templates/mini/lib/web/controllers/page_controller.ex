defmodule DemoLT.Web.PageController do
  use DemoLT.Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
