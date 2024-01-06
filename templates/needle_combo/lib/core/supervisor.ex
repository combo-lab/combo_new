defmodule NeedleCombo.Core.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      NeedleCombo.Core.Telemetry,
      NeedleCombo.Core.Repo,
      {Phoenix.PubSub, name: NeedleCombo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: NeedleCombo.Finch}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
