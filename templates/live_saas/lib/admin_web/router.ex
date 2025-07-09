defmodule LiveSaaS.AdminWeb.Router do
  use LiveSaaS.AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {LiveSaaS.AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LiveSaaS.AdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:live_saas, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
