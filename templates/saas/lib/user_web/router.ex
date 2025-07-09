defmodule ComboLT.UserWeb.Router do
  use ComboLT.UserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {ComboLT.UserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ComboLT.UserWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:combo_lt, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
