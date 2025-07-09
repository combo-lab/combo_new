defmodule ComboLT.UserWeb.PageController do
  use ComboLT.UserWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
