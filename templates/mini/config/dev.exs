import Config

# Do not include metadata nor timestamps in development logs.
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such in
# production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation.
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup.
# Changing it requires `mix clean` and a full recompile.
config :phoenix_live_view, :debug_heex_annotations, true

# Enable helpful, but potentially expensive runtime checks.
config :phoenix_live_view, :enable_expensive_runtime_checks, true

# Enable dev routes
config :combo_lt, dev_routes: true

# Limit running processes, which is good for:
#
#   * inspecting process tree in :observer without too much scrolling
#   * ...
config :combo_lt, process_limit: true

config :combo_lt, ComboLT.Web.Endpoint,
  # http: [
  #   transport_options: [num_acceptors: 2]
  # ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base========================="

config :combo_lt, ComboLT.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/web/(?:router|controllers|layouts|components)(?:/.*)?\.(ex|heex)$",
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$"
    ]
  ]
