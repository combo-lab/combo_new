defmodule MyApp.Web.Supervisor do
  use Supervisor

  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      MyApp.Web.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
