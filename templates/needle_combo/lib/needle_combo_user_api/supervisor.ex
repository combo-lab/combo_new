defmodule NeedleComboUserAPI.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      NeedleComboUserAPI.Telemetry,
      NeedleComboUserAPI.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
