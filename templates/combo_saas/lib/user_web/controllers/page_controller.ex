# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserWeb.PageController do
  use ComboSaaS.UserWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
