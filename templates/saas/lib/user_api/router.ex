defmodule ComboLT.UserAPI.Router do
  use ComboLT.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ComboLT.UserAPI do
    pipe_through :api

    get "/", HomeController, :welcome
  end
end
