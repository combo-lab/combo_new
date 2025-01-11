# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule InertiaSaaS.UserAPI.HomeController do
  use InertiaSaaS.UserAPI, :controller
  alias InertiaSaaS.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
