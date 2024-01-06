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

config :needle_combo, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

# ! core

if config_env() == :prod do
  database_url = fetch_env!.("NEEDLE_COMBO_CORE_DATABASE_URL")

  database_pool_size =
    String.to_integer(System.get_env("NEEDLE_COMBO_CORE_DATABASE_POOL_SIZE") || "10")

  config :needle_combo, NeedleCombo.Core.Repo,
    url: database_url,
    pool_size: database_pool_size

  # Configure the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :needle_combo, NeedleCombo.Core.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("NEEDLE_COMBO_CORE_MAILGUN_API_KEY"),
  #       domain: System.get_env("NEEDLE_COMBO_CORE_MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end

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

config :needle_combo, CozyProxy,
  scheme: :http,
  ip: cozy_proxy_listen_ip,
  port: cozy_proxy_listen_port

if System.get_env("RELEASE_NAME") || System.get_env("COZY_PROXY_SERVER") do
  config :needle_combo, CozyProxy, server: true
end

# ! user_web

config :needle_combo, NeedleCombo.UserWeb.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base = fetch_env!.("NEEDLE_COMBO_USER_WEB_SECRET_KEY_BASE")

    config :needle_combo, NeedleCombo.UserWeb.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :needle_combo, NeedleCombo.UserWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end

# ! user_api

config :needle_combo, NeedleCombo.UserAPI.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base = fetch_env!.("NEEDLE_COMBO_USER_API_SECRET_KEY_BASE")

    config :needle_combo, NeedleCombo.UserAPI.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  _ ->
    :skip
end

# ! admin_web

config :needle_combo, NeedleCombo.AdminWeb.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base = fetch_env!.("NEEDLE_COMBO_ADMIN_WEB_SECRET_KEY_BASE")

    config :needle_combo, NeedleCombo.AdminWeb.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :needle_combo, NeedleCombo.AdminWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end
