defmodule ComboLT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      ComboLT.Telemetry,
      ComboLT.PubSub,
      ComboLT.Core,
      ComboLT.UserWeb,
      ComboLT.UserAPI,
      ComboLT.AdminWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboLT.Telemetry,
      {DNSCluster, dns_cluster_config()},
      ComboLT.PubSub,
      ComboLT.Core.Supervisor,
      ComboLT.UserWeb.Supervisor,
      ComboLT.UserAPI.Supervisor,
      ComboLT.AdminWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ComboLT.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:combo_lt, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    :combo_lt
    |> Application.fetch_env!(CozyProxy)
    |> Keyword.merge(name: CozyProxy.Supervisor)
  end
end
