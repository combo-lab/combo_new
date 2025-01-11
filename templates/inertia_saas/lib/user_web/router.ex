defmodule LiveSaaS.UserWeb.Router do
  use LiveSaaS.UserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveSaaS.UserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LiveSaaS.UserWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:live_saas, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
