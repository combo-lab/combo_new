defmodule DemoLT.Web.Router do
  use DemoLT.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {DemoLT.Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoLT.Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", DemoLT.Web do
    pipe_through :api
  end

  if Application.compile_env(:demo_lt, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
