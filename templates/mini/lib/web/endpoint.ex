defmodule ComboLT.Web.Endpoint do
  use Combo.Endpoint, otp_app: :combo_lt

  # The session will be stored in the cookie and signed, this means its
  # contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_opts [
    store: :cookie,
    key: "_combo_lt_web_key",
    signing_salt: "==signing_salt==",
    same_site: "Lax"
  ]

  # This option controls how many supervisors will be spawned to handle
  # sockets.
  #
  # See `Combo.Socket` for more details.
  @socket_opts if(Application.compile_env(:combo_lt, :process_limit),
                 do: [partitions: 2],
                 else: []
               )
  # suppress unused warning in environments except dev
  _ = @socket_opts

  # Serve at "/" the static files from "priv/user_web/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying the static files in production.
  plug Plug.Static,
    at: "/",
    from: :combo_lt,
    gzip: not code_reloading?,
    only: ComboLT.Web.static_paths()

  # Code reloading can be explicitly enabled under the :code_reloader
  # configuration of the endpoint.
  if code_reloading? do
    # socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket, @socket_opts
    # plug Phoenix.LiveReloader
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
  plug ComboLT.Web.Router
end
