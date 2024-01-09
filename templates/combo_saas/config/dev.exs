import Config

# ! general

# Do not include metadata nor timestamps in development logs.
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such in
# production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation.
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup.
config :phoenix_live_view, :debug_heex_annotations, true

# Enable dev routes for dashboard and mailbox.
config :combo_saas, dev_routes: true

# Limit running processes, which is good for:
#
#   * inspecting process tree in :observer without too much scrolling
#   * ...
config :combo_saas, process_limit: true

# ! cozy_proxy

config :combo_saas, CozyProxy, transport_options: [num_acceptors: 2]

# ! core

# Configure the database.
config :combo_saas, ComboSaaS.Core.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "combo_saas_core_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure the mailer
#
# Use "Local" adapter which stores the emails locally. You can see the emails
# in web browser, at "/dev/mailbox".
config :combo_saas, ComboSaaS.Core.Mailer, adapter: Swoosh.Adapters.Local

# Disable Swoosh API client as it is only required for production adapters.
config :swoosh, :api_client, false

# ! user_web

# Configure the endpoint.
config :combo_saas, ComboSaaS.UserWeb.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../assets/user_web", __DIR__)]
  ]

# Watch static and templates for browser reloading.
config :combo_saas, ComboSaaS.UserWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/user_web/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/user_web/gettext/.*(po)$",
      ~r"lib/user_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# ! user_api

# Configure the endpoint.
config :combo_saas, ComboSaaS.UserAPI.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: []

# ! admin_web

# Configure the endpoint.
config :combo_saas, ComboSaaS.AdminWeb.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../assets/admin_web", __DIR__)]
  ]

# Watch static and templates for browser reloading.
config :combo_saas, ComboSaaS.AdminWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/admin_web/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/admin_web/gettext/.*(po)$",
      ~r"lib/admin_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]
