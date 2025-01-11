defmodule LiveSaaS.UserAPI.Router do
  use LiveSaaS.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", LiveSaaS.UserAPI do
    pipe_through :api

    get "/", HomeController, :welcome
  end
end
