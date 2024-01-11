defmodule ComboSaaS.AdminWeb.Router do
  use ComboSaaS.AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ComboSaaS.AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ComboSaaS.AdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:combo_saas, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If the application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: {ComboSaaS.Telemetry, :metrics}
    end
  end
end
