import Config

# ! general

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :phoenix, :plug_init_mode, :runtime

# ! core

# nothing to do

# ! user_web

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :combo_desktop, ComboDesktop.UserWeb.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4101],
  secret_key_base: "5EAB4oYffh/e3gcDTR4DFndwOyZjcgYtkfpJMExeDK8ROOjZ1EfYu8WW36CH3du0",
  server: false
