defmodule DemoLT.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      DemoLT.PubSub,
      DemoLT.Core.Supervisor,
      DemoLT.Web.Supervisor
    ]

    opts = [strategy: :one_for_one, name: DemoLT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
