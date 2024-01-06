defmodule NeedleComboUserAPI.Router do
  use NeedleComboUserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", NeedleComboUserAPI do
    pipe_through :api
  end
end
