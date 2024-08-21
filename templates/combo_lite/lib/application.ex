defmodule ComboLite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      ComboLite.Telemetry,
      ComboLite.PubSub,
      ComboLite.Core,
      ComboLite.UserWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboLite.Telemetry,
      ComboLite.PubSub,
      {DNSCluster, dns_cluster_config()},
      ComboLite.Core.Supervisor,
      ComboLite.UserWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ComboLite.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:combo_lite, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    :combo_lite
    |> Application.fetch_env!(CozyProxy)
    |> Keyword.merge(name: CozyProxy.Supervisor)
  end
end
