import Config

# Do not print debug messages.
config :logger, level: :info

config :my_app, MyApp.Web.Endpoint,
  inertia: [
    ssr: true
  ]
