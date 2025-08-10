defmodule DemoLT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      DemoLT.Telemetry,
      DemoLT.PubSub,
      DemoLT.Core,
      DemoLT.UserWeb,
      DemoLT.UserAPI,
      DemoLT.AdminWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      DemoLT.Telemetry,
      {DNSCluster, dns_cluster_config()},
      DemoLT.PubSub,
      DemoLT.Core.Supervisor,
      DemoLT.UserWeb.Supervisor,
      DemoLT.UserAPI.Supervisor,
      DemoLT.AdminWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoLT.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:demo_lt, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    :demo_lt
    |> Application.fetch_env!(CozyProxy)
    |> Keyword.merge(name: CozyProxy.Supervisor)
  end
end
