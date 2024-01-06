defmodule NeedleComboApplication do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, dns_cluster_config()},
      NeedleCombo.Supervisor,
      NeedleComboUserWeb.Supervisor,
      NeedleComboUserApi.Supervisor,
      NeedleComboAdminWeb.Supervisor,
      {CozyProxy, cozy_proxy_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NeedleComboApplication.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dns_cluster_config() do
    query = Application.get_env(:needle_combo, :dns_cluster_query) || :ignore
    [query: query]
  end

  defp cozy_proxy_config() do
    Application.fetch_env!(:needle_combo, CozyProxy)
  end
end
