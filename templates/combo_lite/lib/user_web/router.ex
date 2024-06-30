defmodule ComboLite.UserWeb.Router do
  use ComboLite.UserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ComboLite.UserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ComboLite.UserWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:combo_lite, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
