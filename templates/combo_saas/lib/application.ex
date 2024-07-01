defmodule ComboSaaS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      ComboSaaS.Telemetry,
      ComboSaaS.PubSub,
      ComboSaaS.Core,
      ComboSaaS.UserWeb,
      ComboSaaS.UserAPI,
      ComboSaaS.AdminWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboSaaS.Telemetry,
      {DNSCluster, dns_cluster_config()},
      ComboSaaS.PubSub,
      ComboSaaS.Core.Supervisor,
      ComboSaaS.UserWeb.Supervisor,
      ComboSaaS.UserAPI.Supervisor,
      ComboSaaS.AdminWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ComboSaaS.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:combo_saas, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    :combo_saas
    |> Application.fetch_env!(CozyProxy)
    |> Keyword.merge(name: CozyProxy.Supervisor)
  end
end
