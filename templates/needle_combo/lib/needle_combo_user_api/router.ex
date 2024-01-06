defmodule NeedleComboUserApi.Router do
  use NeedleComboUserApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", NeedleComboUserApi do
    pipe_through :api
  end
end
