defmodule ComboLT.Core.Supervisor do
  @moduledoc false

  use Supervisor

  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      ComboLT.Core.Repo,
      # Start the Finch HTTP client for sending emails
      {Finch, name: ComboLT.Core.Finch}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
