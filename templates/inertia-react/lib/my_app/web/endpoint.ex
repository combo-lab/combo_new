defmodule MyApp.Web.Endpoint do
  use Combo.Endpoint, otp_app: :my_app

  plug Plug.Static,
    at: "/",
    from: {:my_app, "priv/static"},
    only: MyApp.Web.static_paths(),
    raise_on_missing_only: MyApp.Env.dev?()

  if live_reloading? do
    socket "/combo/live_reloader/socket", Combo.LiveReloader.Socket
    plug Combo.LiveReloader
  end

  if code_reloading? do
    plug Combo.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:combo, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Combo.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "my_app_web_session",
    signing_salt: "= random_string(8) =",
    same_site: "Lax"

  plug MyApp.Web.Router
end
