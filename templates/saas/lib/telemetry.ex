defmodule DemoLT.Telemetry do
  @moduledoc false

  use Boundary,
    deps: [],
    exports: []

  use Supervisor

  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      # Uncomment following lines when you need telemetry.
      # Check https://hexdocs.pm/cozy_telemetry for more details.
      #
      # {CozyTelemetry.Reporter, config()},
      # {CozyTelemetry.Poller, config()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec metrics :: [Telemetry.Metrics.t()]
  def metrics do
    CozyTelemetry.load_metrics(config())
  end

  defp config do
    Application.fetch_env!(:demo_lt, CozyTelemetry)
  end
end
