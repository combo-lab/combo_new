defmodule NeedleComboUserAPI.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use NeedleComboUserAPI, :controller
  alias NeedleComboUserAPI.MessageJSON

  # def call(
  #       conn,
  #       {:error, %CozyError{} = error}
  #     ) do
  #   message = Exception.message(error)
  #   status = Plug.Exception.status(error)

  #   conn
  #   |> put_status(status)
  #   |> put_view(json: MessageJSON)
  #   |> render(:show, message: message)
  # end
end
