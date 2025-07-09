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

config :combo_lt, CozyTelemetry,
  meta: [],
  specs: [
    ComboLT.Telemetry.VM,
    ComboLT.Telemetry.Phoenix,
    ComboLT.Core.Telemetry
  ],
  reporter: {:console, []},
  poller: [period: 10_000]

# ! cozy_proxy

config :combo_lt, CozyProxy,
  adapter: Bandit,
  http_options: [log_protocol_errors: false],
  backends: [
    %{
      plug: {PlugProbe, path: "/"},
      path: "/probe"
    },
    %{
      plug: ComboLT.AdminWeb.Endpoint,
      path: "/admin"
    },
    %{
      plug: ComboLT.UserAPI.Endpoint,
      path: "/api"
    },
    %{
      plug: ComboLT.UserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :combo_lt, ComboLT.I18n,
  locales: ["en"],
  default_locale: "en"

# ! core

# Configure Mix tasks for Ecto.
config :combo_lt, ecto_repos: [ComboLT.Core.Repo]

# Configures the database.
config :combo_lt, ComboLT.Core.Repo,
  priv: "priv/core/repo",
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# ! user_web

# Configure the endpoint.
config :combo_lt, ComboLT.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ComboLT.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! user_api

# Configure the endpoint.
config :combo_lt, ComboLT.UserAPI.Endpoint,
  url: [path: "/api"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ComboLT.UserAPI.ErrorJSON],
    layout: false
  ],
  pubsub_server: ComboLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! admin_web

# Configure the endpoint.
config :combo_lt, ComboLT.AdminWeb.Endpoint,
  url: [path: "/admin"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ComboLT.AdminWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboLT.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
