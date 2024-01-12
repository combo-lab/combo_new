defmodule ComboLite.Telemetry do
  @moduledoc false

  use Boundary,
    deps: [],
    exports: []

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Uncomment it when you need a reporter.
      # Check https://hexdocs.pm/cozy_telemetry for more details.
      # {CozyTelemetry.Reporter, config()},
      {CozyTelemetry.Poller, config()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    CozyTelemetry.load_metrics(config())
  end

  defp config do
    Application.fetch_env!(:combo_lite, CozyTelemetry)
  end
end
