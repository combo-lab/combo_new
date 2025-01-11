defmodule LiveSaaS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      LiveSaaS.Telemetry,
      LiveSaaS.PubSub,
      LiveSaaS.Core,
      LiveSaaS.UserWeb,
      LiveSaaS.UserAPI,
      LiveSaaS.AdminWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      LiveSaaS.Telemetry,
      {DNSCluster, dns_cluster_config()},
      LiveSaaS.PubSub,
      LiveSaaS.Core.Supervisor,
      LiveSaaS.UserWeb.Supervisor,
      LiveSaaS.UserAPI.Supervisor,
      LiveSaaS.AdminWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveSaaS.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:live_saas, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    :live_saas
    |> Application.fetch_env!(CozyProxy)
    |> Keyword.merge(name: CozyProxy.Supervisor)
  end
end
