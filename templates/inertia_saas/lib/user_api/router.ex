defmodule InertiaSaaS.UserAPI.Router do
  use InertiaSaaS.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", InertiaSaaS.UserAPI do
    pipe_through :api

    get "/", HomeController, :welcome
  end
end
