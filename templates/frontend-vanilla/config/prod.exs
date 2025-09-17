import Config

# Do not print debug messages.
config :logger, level: :info

config :my_app, MyApp.Web.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
