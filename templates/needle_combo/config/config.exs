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

# ! cozy_proxy

config :needle_combo, CozyProxy,
  backends: [
    %{
      plug: {PlugProbe, path: "/"},
      path: "/probe"
    },
    %{
      plug: NeedleCombo.AdminWeb.Endpoint,
      path: "/admin"
    },
    %{
      plug: NeedleCombo.UserAPI.Endpoint,
      path: "/api"
    },
    %{
      plug: NeedleCombo.UserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :needle_combo, NeedleCombo.I18n,
  default_locale: "en",
  locales: ["en"]

# Tasks like `mix gettext.merge` use the plural backend configured under the :gettext
# application, so the following global configuration approach is preferred.
config :gettext,
  plural_forms: NeedleCombo.I18n.Gettext.Plural

config :ex_cldr,
  default_backend: NeedleCombo.I18n.Cldr,
  json_library: Jason

# ! core

# Configure Mix tasks for Ecto.
config :needle_combo, ecto_repos: [NeedleCombo.Core.Repo]

# Configures the database
config :needle_combo, NeedleCombo.Core.Repo,
  priv: "priv/core/repo",
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# ! user_web

# Configure the endpoint.
config :needle_combo, NeedleCombo.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: NeedleCombo.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# ! user_api

# Configure the endpoint.
config :needle_combo, NeedleCombo.UserAPI.Endpoint,
  url: [path: "/api"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: NeedleCombo.UserAPI.ErrorJSON],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# ! admin_web

# Configure the endpoint.
config :needle_combo, NeedleCombo.AdminWeb.Endpoint,
  url: [path: "/admin"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: NeedleCombo.AdminWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
