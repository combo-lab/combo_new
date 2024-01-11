defmodule ComboSaaS.Core.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      ComboSaaS.Core.Repo,
      {Phoenix.PubSub, name: ComboSaaS.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ComboSaaS.Core.Finch}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
