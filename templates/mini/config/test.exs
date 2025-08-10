import Config

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :combo, :plug_init_mode, :runtime

# Configure the endpoint
#
# Don't run a server during test. If one is required, enable the :server
# option below.
config :combo_lt, ComboLT.Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4101],
  secret_key_base: "=========================secret_key_base=========================",
  server: false
