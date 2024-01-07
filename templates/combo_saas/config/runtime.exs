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

split_by_comma = fn string ->
  string
  |> String.trim()
  |> String.split(~r/,\s*/)
  |> Enum.reject(&(&1 == ""))
end

# ! general

config :combo_saas, :dns_cluster_query, CozyEnv.get_env("DNS_CLUSTER_QUERY")

# ! cozy_proxy

cozy_proxy_endpoint = CozyEnv.get_env("COZY_PROXY_ENDPOINT") || "http://localhost:4000"
cozy_proxy_extra_endpoints = CozyEnv.get_env("COZY_PROXY_EXTRA_ENDPOINTS")
cozy_proxy_custom_listen_port = CozyEnv.get_env("COZY_PROXY_LISTEN_PORT", :integer)
cozy_proxy_parsed_endpoint = parse_endpoint.(cozy_proxy_endpoint)
cozy_proxy_derived_host = Keyword.fetch!(cozy_proxy_parsed_endpoint, :host)
cozy_proxy_derived_port = Keyword.fetch!(cozy_proxy_parsed_endpoint, :port)

cozy_proxy_listen_ip =
  if cozy_proxy_derived_host in ["127.0.0.1", "localhost"],
    do: {127, 0, 0, 1},
    else: {0, 0, 0, 0}

cozy_proxy_listen_port =
  if cozy_proxy_custom_listen_port,
    do: cozy_proxy_custom_listen_port,
    else: cozy_proxy_derived_port

cozy_proxy_origin =
  [cozy_proxy_endpoint] ++
    if cozy_proxy_extra_endpoints, do: split_by_comma.(cozy_proxy_extra_endpoints), else: []

config :combo_saas, CozyProxy,
  scheme: :http,
  ip: cozy_proxy_listen_ip,
  port: cozy_proxy_listen_port

if CozyEnv.get_env("RELEASE_NAME") || CozyEnv.get_env("COZY_PROXY_SERVER") do
  config :combo_saas, CozyProxy, server: true
end

# ! ecto

ecto_socket_options = if CozyEnv.get_env("ECTO_IPV6", :boolean), do: [:inet6], else: []

# ! core

if config_env() == :prod do
  database_url =
    CozyEnv.fetch_env!("COMBO_SAAS_CORE_DATABASE_URL",
      message: "Set it to something like: ecto://USER:PASS@HOST/DATABASE"
    )

  database_pool_size = CozyEnv.get_env("COMBO_SAAS_CORE_DATABASE_POOL_SIZE", :integer) || 10

  config :combo_saas, ComboSaaS.Core.Repo,
    url: database_url,
    pool_size: database_pool_size,
    socket_options: ecto_socket_options

  # Configure the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :combo_saas, ComboSaaS.Core.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: CozyEnv.fetch_env!("COMBO_SAAS_CORE_MAILGUN_API_KEY"),
  #       domain: CozyEnv.fetch_env!("COMBO_SAAS_CORE_MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end

# ! user_web

config :combo_saas, ComboSaaS.UserWeb.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base =
      CozyEnv.fetch_env!("COMBO_SAAS_USER_WEB_SECRET_KEY_BASE",
        message: "Generate one by calling: mix phx.gen.secret"
      )

    config :combo_saas, ComboSaaS.UserWeb.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :combo_saas, ComboSaaS.UserWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end

# ! user_api

config :combo_saas, ComboSaaS.UserAPI.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base =
      CozyEnv.fetch_env!("COMBO_SAAS_USER_API_SECRET_KEY_BASE",
        message: "Generate one by calling: mix phx.gen.secret"
      )

    config :combo_saas, ComboSaaS.UserAPI.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  _ ->
    :skip
end

# ! admin_web

config :combo_saas, ComboSaaS.AdminWeb.Endpoint, url: cozy_proxy_parsed_endpoint

case config_env() do
  :prod ->
    secret_key_base =
      CozyEnv.fetch_env!("COMBO_SAAS_ADMIN_WEB_SECRET_KEY_BASE",
        message: "Generate one by calling: mix phx.gen.secret"
      )

    config :combo_saas, ComboSaaS.AdminWeb.Endpoint,
      secret_key_base: secret_key_base,
      check_origin: cozy_proxy_origin

  :dev ->
    force_watchers = Application.get_env(:phoenix, :serve_endpoints, false)
    config :combo_saas, ComboSaaS.AdminWeb.Endpoint, force_watchers: force_watchers

  _ ->
    :skip
end
