# This file is responsible for general configuration of the application and
# its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and is restricted
# to this project.

import Config

# ! general

# Configure Elixir's Logger.
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix.
config :phoenix, :json_library, Jason

# ! cozy_telemetry

config :demo_lt, CozyTelemetry,
  meta: [],
  specs: [
    DemoLT.Telemetry.VM,
    DemoLT.Telemetry.Phoenix,
    DemoLT.Core.Telemetry
  ],
  reporter: {:console, []},
  poller: [period: 10_000]

# ! cozy_proxy

config :demo_lt, CozyProxy,
  adapter: Bandit,
  http_options: [log_protocol_errors: false],
  backends: [
    %{
      plug: {PlugProbe, path: "/"},
      path: "/probe"
    },
    %{
      plug: DemoLT.AdminWeb.Endpoint,
      path: "/admin"
    },
    %{
      plug: DemoLT.UserAPI.Endpoint,
      path: "/api"
    },
    %{
      plug: DemoLT.UserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :demo_lt, DemoLT.I18n,
  locales: ["en"],
  default_locale: "en"

# ! core

# Configure Mix tasks for Ecto.
config :demo_lt, ecto_repos: [DemoLT.Core.Repo]

# Configures the database.
config :demo_lt, DemoLT.Core.Repo,
  priv: "priv/core/repo",
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# ! user_web

# Configure the endpoint.
config :demo_lt, DemoLT.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DemoLT.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: DemoLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! user_api

# Configure the endpoint.
config :demo_lt, DemoLT.UserAPI.Endpoint,
  url: [path: "/api"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: DemoLT.UserAPI.ErrorJSON],
    layout: false
  ],
  pubsub_server: DemoLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! admin_web

# Configure the endpoint.
config :demo_lt, DemoLT.AdminWeb.Endpoint,
  url: [path: "/admin"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DemoLT.AdminWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: DemoLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
