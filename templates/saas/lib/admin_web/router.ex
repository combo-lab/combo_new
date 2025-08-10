defmodule DemoLT.AdminWeb.Router do
  use DemoLT.AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {DemoLT.AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", DemoLT.AdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:demo_lt, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
