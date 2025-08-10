defmodule DemoLT.UserAPI.HomeController do
  use DemoLT.UserAPI, :controller
  alias DemoLT.UserAPI.MessageJSON

  def welcome(conn, _) do
    message = "Welcome to the UserAPI world!"

    conn
    |> put_view(json: MessageJSON)
    |> render(:show, message: message)
  end
end
