defmodule NeedleCombo.UserAPI.Router do
  use NeedleCombo.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", NeedleCombo.UserAPI do
    pipe_through :api
  end
end
