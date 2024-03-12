import Config

# ! general

# Do not include metadata nor timestamps in development logs.
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such in
# production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation.
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup.
config :phoenix_live_view, :debug_heex_annotations, true

# Enable helpful, but potentially expensive runtime checks.
config :phoenix_live_view, :enable_expensive_runtime_checks, true

# Enable dev routes for dashboard and mailbox.
config :combo_lite, dev_routes: true

# Limit running processes, which is good for:
#
#   * inspecting process tree in :observer without too much scrolling
#   * ...
config :combo_lite, process_limit: true

# ! cozy_proxy

config :combo_lite, CozyProxy, thousand_island_options: [num_acceptors: 2]

# ! core

# nothing to do

# ! user_web

# Configure the endpoint.
config :combo_lite, ComboLite.UserWeb.Endpoint,
  http: [
    thousand_island_options: [num_acceptors: 2]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base=========================",
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../assets/user_web", __DIR__)]
  ]

# Watch static and templates for browser reloading.
config :combo_lite, ComboLite.UserWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/user_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"priv/user_web/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/i18n/gettext/.*(po)$"
    ]
  ]
