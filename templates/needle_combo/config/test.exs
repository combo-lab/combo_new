import Config

# ! general

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :phoenix, :plug_init_mode, :runtime

# ! needle_combo

# Configure the database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :needle_combo, NeedleCombo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "needle_combo_test#{System.get_env("NEEDLE_COMBO_MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Configure the mailer
#
# In test we don't send emails.
config :needle_combo, NeedleCombo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# ! needle_combo_user_web

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :needle_combo, NeedleComboUserWeb.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4101],
  secret_key_base: "=========================secret_key_base=========================",
  server: false

# ! needle_combo_user_api

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :needle_combo, NeedleComboUserAPI.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4102],
  secret_key_base: "=========================secret_key_base=========================",
  server: false

# ! needle_combo_admin_web

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :needle_combo, NeedleComboAdminWeb.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4103],
  secret_key_base: "=========================secret_key_base=========================",
  server: false
