import Config

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :combo, :json_module, Jason

config :demo_lt, DemoLT.Web.Endpoint,
  render_errors: [
    layout: [html: false, json: false],
    formats: [html: DemoLT.Web.ErrorHTML, json: DemoLT.Web.ErrorJSON]
  ],
  pubsub_server: DemoLT.PubSub

# Import environment specific config
#
# This must remain at the bottom of this file so it overrides the config
# defined above.
import_config "#{config_env()}.exs"
