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
config :needle_combo, dev_routes: true

# Limit running processes, which is good for:
#
#   * inspecting process tree in :observer without too much scrolling
#   * ...
config :needle_combo, process_limit: true

# ! cozy_proxy

config :needle_combo, CozyProxy, transport_options: [num_acceptors: 2]

# ! needle_combo

# Configure the database
config :needle_combo, NeedleCombo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "needle_combo_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure the mailer
#
# Use "Local" adapter which stores the emails locally. You can see the emails
# in web browser, at "/dev/mailbox".
config :needle_combo, NeedleCombo.Mailer, adapter: Swoosh.Adapters.Local

# Disable Swoosh API client as it is only required for production adapters.
config :swoosh, :api_client, false

# ! needle_combo_user_web

# Configure the endpoint
config :needle_combo, NeedleComboUserWeb.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../assets/needle_combo_user_web", __DIR__)]
  ]

# Watch static and templates for browser reloading.
config :needle_combo, NeedleComboUserWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/needle_combo_user_web/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/needle_combo_user_web/gettext/.*(po)$",
      ~r"lib/needle_combo_user_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# ! needle_combo_user_api

# Configure the endpoint
config :needle_combo, NeedleComboUserAPI.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: []

# ! needle_combo_admin_web

# Configure the endpoint
config :needle_combo, NeedleComboAdminWeb.Endpoint,
  http: [
    transport_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../assets/needle_combo_admin_web", __DIR__)]
  ]

# Watch static and templates for browser reloading.
config :needle_combo, NeedleComboAdminWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/needle_combo_admin_web/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/needle_combo_admin_web/gettext/.*(po)$",
      ~r"lib/needle_combo_admin_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]
