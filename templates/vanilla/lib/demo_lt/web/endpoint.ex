defmodule DemoLT.Web.Endpoint do
  use Combo.Endpoint, otp_app: :demo_lt

  # The session will be stored in the cookie and signed, this means its
  # contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_opts [
    store: :cookie,
    key: "_combo_lt_web_key",
    signing_salt: "==signing_salt==",
    same_site: "Lax"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying the static files in production.
  plug Plug.Static,
    at: "/",
    from: :demo_lt,
    gzip: not code_reloading?,
    only: DemoLT.Web.static_paths()

  if live_reloading? do
    socket "/combo/live_reload/socket", Combo.LiveReloader.Socket
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
    json_decoder: Combo.json_module()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_opts
  plug DemoLT.Web.Router
end
