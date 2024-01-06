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
      plug: NeedleComboAdminWeb.Endpoint,
      path: "/admin"
    },
    %{
      plug: NeedleComboUserAPI.Endpoint,
      path: "/api"
    },
    %{
      plug: NeedleComboUserWeb.Endpoint,
      path: "/"
    }
  ]

# ! i18n

config :needle_combo, I18n,
  default_locale: "en",
  locales: ["en"]

# Tasks like `mix gettext.merge` use the plural backend configured under the :gettext
# application, so the following global configuration approach is preferred.
config :gettext,
  plural_forms: I18n.Gettext.Plural

config :ex_cldr,
  default_backend: I18n.Cldr,
  json_library: Jason

# ! needle_combo

# Configure Mix tasks for Ecto.
config :needle_combo, ecto_repos: [NeedleCombo.Repo]

# Configures the database
config :needle_combo, NeedleCombo.Repo,
  priv: "priv/needle_combo/repo",
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# ! needle_combo_user_web

# Configure the endpoint.
config :needle_combo, NeedleComboUserWeb.Endpoint,
  url: [path: "/"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: NeedleComboUserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# ! needle_combo_user_api

# Configure the endpoint.
config :needle_combo, NeedleComboUserAPI.Endpoint,
  url: [path: "/api"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: NeedleComboUserAPI.ErrorJSON],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# ! needle_combo_admin_web

# Configure the endpoint.
config :needle_combo, NeedleComboAdminWeb.Endpoint,
  url: [path: "/admin"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: NeedleComboAdminWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: NeedleCombo.PubSub,
  live_view: [signing_salt: "==salt=="],
  server: false

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
