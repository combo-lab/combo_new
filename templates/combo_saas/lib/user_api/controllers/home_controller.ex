# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserAPI.HomeController do
  use ComboSaaS.UserAPI, :controller
  alias ComboSaaS.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
