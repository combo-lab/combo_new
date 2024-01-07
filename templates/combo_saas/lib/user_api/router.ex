defmodule ComboSaaS.UserAPI.Router do
  use ComboSaaS.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", ComboSaaS.UserAPI do
    pipe_through :api

    get "/", HomeController, :welcome
  end
end
