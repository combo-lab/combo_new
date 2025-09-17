import Config

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :my_app, ecto_repos: [MyApp.Core.Repo]

config :my_app, MyApp.Core.Repo,
  priv: "priv/repo",
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

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
