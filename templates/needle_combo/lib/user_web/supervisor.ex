defmodule NeedleCombo.UserWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      NeedleCombo.UserWeb.Telemetry,
      NeedleCombo.UserWeb.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
