# This file is executed for all environments, including during releases.
#
# It is executed after compilation and before the system starts, so it is
# typically used to load production configuration and secrets from environment
# variables or elsewhere. Do not define any compile-time configuration in here,
# as it won't be applied.

import Config

parse_endpoint = fn url ->
  %URI{scheme: scheme, host: host, port: port} = URI.parse(url)
  [scheme: scheme, host: host, port: port]
end

fetch_env! = fn env ->
  System.get_env(env) ||
    raise "environment variable #{env} is missing."
end

split_by_comma = fn string ->
  string
  |> String.trim()
  |> String.split(~r/,\s*/)
  |> Enum.reject(&(&1 == ""))
end

# ! general

config :combo_lite, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

# ! cozy_proxy

cozy_proxy_endpoint = System.get_env("COZY_PROXY_ENDPOINT") || "http://localhost:4000"
cozy_proxy_extra_endpoints = System.get_env("COZY_PROXY_EXTRA_ENDPOINTS")
cozy_proxy_custom_listen_port = System.get_env("COZY_PROXY_LISTEN_PORT")
cozy_proxy_parsed_endpoint = parse_endpoint.(cozy_proxy_endpoint)
cozy_proxy_derived_host = Keyword.fetch!(cozy_proxy_parsed_endpoint, :host)
cozy_proxy_derived_port = Keyword.fetch!(cozy_proxy_parsed_endpoint, :port)

cozy_proxy_listen_ip =
  if cozy_proxy_derived_host in ["127.0.0.1", "localhost"],
    do: {127, 0, 0, 1},
    else: {0, 0, 0, 0}

cozy_proxy_listen_port =
  if cozy_proxy_custom_listen_port,
    do: String.to_integer(cozy_proxy_custom_listen_port),
    else: cozy_proxy_derived_port

cozy_proxy_origin =
  [cozy_proxy_endpoint] ++
    if cozy_proxy_extra_endpoints, do: split_by_comma.(cozy_proxy_extra_endpoints), else: []

config :combo_lite, CozyProxy,
  scheme: :http,
  ip: cozy_proxy_listen_ip,
  port: cozy_proxy_listen_port

if System.get_env("RELEASE_NAME") || System.get_env("COZY_PROXY_SERVER") do
  config :combo_lite, CozyProxy, server: true
end

# ! core

# nothing to do

# ! user_web

config :combo_lite, ComboLite.UserWeb.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base = fetch_env!.("COMBO_SAAS_USER_WEB_SECRET_KEY_BASE")

    config :combo_lite, ComboLite.UserWeb.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :combo_lite, ComboLite.UserWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end
