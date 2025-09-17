import Config

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :combo, :plug_init_mode, :runtime

# Configure the database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :my_app, MyApp.Core.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "my_app_test#{System.get_env("MY_APP_MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# Configure the endpoint
#
# Don't run a server during test. If one is required, enable the :server
# option below.
config :my_app, MyApp.Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4101],
  secret_key_base: "======================= random_string(65) =======================",
  server: false
