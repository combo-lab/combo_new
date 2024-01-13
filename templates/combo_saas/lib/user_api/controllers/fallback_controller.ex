# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserAPI.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use ComboSaaS.UserAPI, :controller
end
