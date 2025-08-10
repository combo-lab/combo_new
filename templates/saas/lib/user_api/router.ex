defmodule DemoLT.UserAPI.Router do
  use DemoLT.UserAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoLT.UserAPI do
    pipe_through :api

    get "/", HomeController, :welcome
  end
end
