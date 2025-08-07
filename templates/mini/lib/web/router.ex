defmodule ComboLT.Web.Router do
  use ComboLT.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {ComboLT.Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ComboLT.Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", ComboLT.Web do
    pipe_through :api
  end

  if Application.compile_env(:combo_lt, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
