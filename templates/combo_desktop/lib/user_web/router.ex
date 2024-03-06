defmodule ComboDesktop.UserWeb.Router do
  use ComboDesktop.UserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ComboDesktop.UserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ComboDesktop.UserWeb do
    pipe_through :browser

    get "/", PageController, :home
  end
end
