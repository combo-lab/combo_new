defmodule ComboSaaS.UserWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :combo_saas

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_combo_saas_user_web_key",
    signing_salt: "==signing_salt==",
    same_site: "Lax"
  ]

  # This option controls how many supervisors will be spawned to handle sockets.
  # See `Phoenix.Socket` for more details.
  @socket_partitions_options if(Application.compile_env(:combo_saas, :process_limit),
                               do: [partitions: 2],
                               else: []
                             )

  socket "/live",
         Phoenix.LiveView.Socket,
         [
           websocket: [connect_info: [session: @session_options]],
           longpoll: [connect_info: [session: @session_options]]
         ] ++ @socket_partitions_options

  # Serve at "/" the static files from "priv/user_web/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying the static files in production.
  plug Plug.Static,
    at: "/",
    from: {:combo_saas, "priv/user_web/static"},
    gzip: false,
    only: ComboSaaS.UserWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of the endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket",
           Phoenix.LiveReloader.Socket,
           @socket_partitions_options

    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ComboSaaS.UserWeb.Router
end
