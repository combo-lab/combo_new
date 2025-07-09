defmodule ComboLT.AdminWeb.PageController do
  use ComboLT.AdminWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
