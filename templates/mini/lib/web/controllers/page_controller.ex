defmodule ComboLT.Web.PageController do
  use ComboLT.Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
