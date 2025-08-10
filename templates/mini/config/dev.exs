import Config

# Do not include metadata nor timestamps in development logs.
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such in
# production as building large stacktraces may be expensive.
config :combo, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation.
config :combo, :plug_init_mode, :runtime

# Include CEEx debug annotations as HTML comments in rendered markup.
# Changing it requires `mix clean` and a full recompile.
config :combo, :ceex_debug_annotations, true

# Enable dev routes
config :demo_lt, dev_routes: true

# Limit running processes, which is good for:
#
#   * inspecting process tree in :observer without too much scrolling
#   * ...
config :demo_lt, process_limit: true

config :demo_lt, DemoLT.Web.Endpoint,
  # http: [
  #   transport_options: [num_acceptors: 2]
  # ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base========================="

config :demo_lt, DemoLT.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/web/(?:router|controllers|layouts|components)(?:/.*)?\.(ex|ceex)$",
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$"
    ]
  ]
