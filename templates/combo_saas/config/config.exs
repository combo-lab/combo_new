# This file is responsible for general configuration of the application and
# its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and is restricted
# to this project.

import Config

# ! general

# Configure Elixir's Logger.
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix.
config :phoenix, :json_library, Jason

# ! cozy_telemetry

config :combo_saas, CozyTelemetry,
  meta: [],
  specs: [
    ComboSaaS.Telemetry.VM,
    ComboSaaS.Telemetry.Phoenix,
    ComboSaaS.Core.Telemetry
  ],
  reporter: {:console, []},
  poller: [period: 10_000]

# ! cozy_proxy

config :combo_saas, CozyProxy,
  backends: [
    %{
      plug: {PlugProbe, path: "/"},
      path: "/probe"
    },
    %{
      plug: ComboSaaS.AdminWeb.Endpoint,
      path: "/admin"
    },
    %{
      plug: ComboSaaS.UserAPI.Endpoint,
      path: "/api"
    },
    %{
      plug: ComboSaaS.UserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :combo_saas, ComboSaaS.I18n,
  default_locale: "en",
  locales: ["en"]

# Tasks like `mix gettext.merge` use the plural backend configured under the
# :gettext application, so the following global configuration approach is
# preferred.
config :gettext,
  plural_forms: ComboSaaS.I18n.Gettext.Plural

config :ex_cldr,
  default_backend: ComboSaaS.I18n.Cldr,
  json_library: Jason

# ! core

# Configure Mix tasks for Ecto.
config :combo_saas, ecto_repos: [ComboSaaS.Core.Repo]

# ! user_web

# Configure the endpoint.
config :combo_saas, ComboSaaS.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: ComboSaaS.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboSaaS.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! user_api

# Configure the endpoint.
config :combo_saas, ComboSaaS.UserAPI.Endpoint,
  url: [path: "/api"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: ComboSaaS.UserAPI.ErrorJSON],
    layout: false
  ],
  pubsub_server: ComboSaaS.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# ! admin_web

# Configure the endpoint.
config :combo_saas, ComboSaaS.AdminWeb.Endpoint,
  url: [path: "/admin"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: ComboSaaS.AdminWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboSaaS.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
