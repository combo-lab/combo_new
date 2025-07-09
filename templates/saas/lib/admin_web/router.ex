defmodule ComboLT.AdminWeb.Router do
  use ComboLT.AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {ComboLT.AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ComboLT.AdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:combo_lt, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
    end
  end
end
