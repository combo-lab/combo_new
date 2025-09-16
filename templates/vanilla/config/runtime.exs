# This file is executed for all environments, including during releases.
#
# It is executed after compilation and before the system starts, so it is
# typically used to load production configuration and secrets from environment
# variables or elsewhere. Do not define any compile-time configuration in here,
# as it won't be applied.

import Config

base_url = SystemEnv.get_env("BASE_URL") || "http://localhost:4000"

parse_url = fn url ->
  %URI{scheme: scheme, host: host, port: port} = URI.parse(url)
  [scheme: scheme, host: host, port: port]
end

parsed_url = parse_url.(base_url)
derived_host = Keyword.fetch!(parsed_url, :host)
derived_port = Keyword.fetch!(parsed_url, :port)

listen_ip =
  if derived_host in ["127.0.0.1", "localhost"],
    do: {127, 0, 0, 1},
    else: {0, 0, 0, 0}

listen_port =
  if custom_port = SystemEnv.get_env("LISTEN_PORT", :integer),
    do: custom_port,
    else: derived_port

origins = [base_url]

config :my_app, MyApp.Web.Endpoint,
  url: parsed_url,
  http: [
    ip: listen_ip,
    port: listen_port
  ]

case config_env() do
  :prod ->
    secret_key_base =
      SystemEnv.fetch_env!("SECRET_KEY_BASE",
        message: "Generate one by calling: mix combo.gen.secret"
      )

    config :my_app, MyApp.Web.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: origins

  _ ->
    :skip
end

if SystemEnv.get_env("RELEASE_NAME") do
  config :my_app, MyApp.Web.Endpoint, server: true
end
