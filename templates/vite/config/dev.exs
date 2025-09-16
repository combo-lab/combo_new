import Config

# Do not include metadata nor timestamps in development logs.
config :logger, :default_formatter, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation.
config :combo, :plug_init_mode, :runtime

# Include CEEx debug annotations as HTML comments in rendered markup.
# Changing it requires `mix clean` and a full recompile.
config :combo, :template, ceex_debug_annotations: true

# Set a higher stacktrace during development.
# Avoid configuring it in production as building large stacktraces may be expensive.
config :my_app, :stacktrace_depth, 20

# Enable dev routes
config :my_app, dev_routes: true

config :my_app, MyApp.Web.Endpoint,
  check_origin: false,
  live_reloader: [
    patterns: [
      ~r"lib/my_app/web/router\.ex",
      ~r"lib/my_app/web/(controllers|layouts|components)/.*\.(ex|ceex)$"
    ]
  ],
  code_reloader: true,
  watchers: [
    npm: [
      "run",
      "dev",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  process_limit: 2,
  force_ssl: false,
  debug_errors: true,
  secret_key_base: "=========================secret_key_base========================="
