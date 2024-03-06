# This file is executed for all environments, including during releases.
#
# It is executed after compilation and before the system starts, so it is
# typically used to load production configuration and secrets from environment
# variables or elsewhere. Do not define any compile-time configuration in here,
# as it won't be applied.

import Config

# ! core

# nothing to do

# ! user_web

# config :combo_desktop, ComboDesktop.UserWeb.Endpoint,
#   http: [ip: {127, 0, 0, 1}, port: 0],
#   server: true

case config_env() do
  :prod ->
    secret_key_base =
      CozyEnv.fetch_env!("COMBO_DESKTOP_USER_WEB_SECRET_KEY_BASE",
        message: "Generate one by calling: mix phx.gen.secret"
      )

    config :combo_desktop, ComboDesktop.UserWeb.Endpoint, secret_key_base: secret_key_base

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :combo_desktop, ComboDesktop.UserWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end
