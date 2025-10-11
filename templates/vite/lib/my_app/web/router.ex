defmodule MyApp.Web.Router do
  use MyApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_layout, html: {MyApp.Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Combo.Vite.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyApp.Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", MyApp.Web do
    pipe_through :api
  end

  if MyApp.Env.dev?() do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
