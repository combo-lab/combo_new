import Config

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :combo, :json_module, Jason

config :combo_lt, ComboLT.Web.Endpoint,
  adapter: Combo.Endpoint.BanditAdapter,
  render_errors: [
    formats: [html: ComboLT.Web.ErrorHTML, json: ComboLT.Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: ComboLT.PubSub

# Import environment specific config
#
# This must remain at the bottom of this file so it overrides the config
# defined above.
import_config "#{config_env()}.exs"
