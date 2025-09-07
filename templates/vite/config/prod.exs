import Config

# Do not print debug messages.
config :logger, level: :info

config :demo_lt, DemoLT.Web.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
