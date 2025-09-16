import Config

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :my_app, MyApp.Web.Endpoint,
  render_errors: [
    layout: [html: false, json: false],
    formats: [html: MyApp.Web.ErrorHTML, json: MyApp.Web.ErrorJSON]
  ],
  pubsub_server: MyApp.PubSub

# Import environment specific config
#
# This must remain at the bottom of this file so it overrides the config
# defined above.
import_config "#{config_env()}.exs"
