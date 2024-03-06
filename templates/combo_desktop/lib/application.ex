defmodule ComboDesktop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      ComboDesktop.Telemetry,
      ComboDesktop.PubSub,
      ComboDesktop.Core,
      ComboDesktop.UserWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboDesktop.Telemetry,
      ComboDesktop.PubSub,
      {DNSCluster, dns_cluster_config()},
      ComboDesktop.Core.Supervisor,
      ComboDesktop.UserWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ComboDesktop.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config do
    query = Application.get_env(:combo_desktop, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config do
    Application.fetch_env!(:combo_desktop, CozyProxy)
  end
end
