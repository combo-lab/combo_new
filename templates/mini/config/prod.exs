import Config

# Do not print debug messages.
config :logger, level: :info

config :combo_lt, ComboLT.Web.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
