defmodule ComboDesktop.UserWeb.Supervisor do
  @moduledoc false

  use Supervisor

  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      ComboDesktop.UserWeb.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
