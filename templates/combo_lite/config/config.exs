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

config :combo_lite, CozyTelemetry,
  meta: [],
  specs: [
    ComboLite.Telemetry.VM,
    ComboLite.Telemetry.Phoenix
  ],
  reporter: {:console, []},
  poller: [period: 10_000]

# ! cozy_proxy

config :combo_lite, CozyProxy,
  backends: [
    %{
      plug: {PlugProbe, path: "/"},
      path: "/probe"
    },
    %{
      plug: ComboLite.UserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :combo_lite, ComboLite.I18n,
  locales: ["en"],
  default_locale: "en"

# Tasks like `mix gettext.merge` use the plural backend configured under the
# :gettext application, so the following global configuration approach is
# preferred.
config :gettext,
  plural_forms: ComboLite.I18n.Gettext.Plural

config :ex_cldr,
  default_backend: ComboLite.I18n.Cldr,
  json_library: Jason

# ! core

# nothing to do

# ! user_web

# Configure the endpoint.
config :combo_lite, ComboLite.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: ComboLite.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboLite.PubSub,
  live_view: [signing_salt: "==signing_salt=="],
  server: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
