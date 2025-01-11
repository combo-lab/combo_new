# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule LiveSaaS.UserWeb.PageController do
  use LiveSaaS.UserWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
