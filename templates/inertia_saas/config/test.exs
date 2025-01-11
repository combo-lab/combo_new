import Config

# ! general

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks.
config :phoenix_live_view, :enable_expensive_runtime_checks, true

# ! core

# Configure the database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :inertia_saas, InertiaSaaS.Core.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "inertia_saas_core_test#{System.get_env("INERTIA_SAAS_CORE_MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# Configure the mailer
#
# In test we don't send emails.
config :inertia_saas, InertiaSaaS.Core.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# ! user_web

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :inertia_saas, InertiaSaaS.UserWeb.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4101],
  secret_key_base: "=========================secret_key_base=========================",
  server: false

# ! user_api

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :inertia_saas, InertiaSaaS.UserAPI.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4102],
  secret_key_base: "=========================secret_key_base=========================",
  server: false

# ! admin_web

# Configure the endpoint
#
# We don't run a server during test. If one is required, you can enable the
# server option below.
config :inertia_saas, InertiaSaaS.AdminWeb.Endpoint,
  url: [path: "/"],
  http: [ip: {127, 0, 0, 1}, port: 4103],
  secret_key_base: "=========================secret_key_base=========================",
  server: false
