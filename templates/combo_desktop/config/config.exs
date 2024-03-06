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

# ! i18n

config :combo_desktop, ComboDesktop.I18n,
  locales: ["en"],
  default_locale: "en"

# ! core

# nothing to do

# ! user_web

# Configure the endpoint.
config :combo_desktop, ComboDesktop.UserWeb.Endpoint,
  url: [path: "/"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ComboDesktop.UserWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: ComboDesktop.PubSub,
  live_view: [signing_salt: "+l93LYg6"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
