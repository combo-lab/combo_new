# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule LiveSaaS.UserAPI.HomeController do
  use LiveSaaS.UserAPI, :controller
  alias LiveSaaS.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
