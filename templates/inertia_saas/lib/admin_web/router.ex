defmodule InertiaSaaS.AdminWeb.Router do
  use InertiaSaaS.AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InertiaSaaS.AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", InertiaSaaS.AdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:inertia_saas, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
