defmodule NeedleCombo.UserAPI.HomeController do
  use NeedleCombo.UserAPI, :controller
  alias NeedleCombo.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
