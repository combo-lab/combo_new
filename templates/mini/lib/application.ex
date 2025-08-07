defmodule ComboLT.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboLT.PubSub,
      ComboLT.Core.Supervisor,
      ComboLT.Web.Supervisor
    ]

    opts = [strategy: :one_for_one, name: ComboLT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
