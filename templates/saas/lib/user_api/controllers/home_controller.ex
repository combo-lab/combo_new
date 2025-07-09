defmodule ComboLT.UserAPI.HomeController do
  use ComboLT.UserAPI, :controller
  alias ComboLT.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
