defmodule DemoLT.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    if stacktrace_depth = Application.get_env(:demo_lt, :stacktrace_depth, nil) do
      :erlang.system_flag(:backtrace_depth, stacktrace_depth)
    end

    children = [
      DemoLT.PubSub,
      DemoLT.Core.Supervisor,
      DemoLT.Web.Supervisor
    ]

    opts = [strategy: :one_for_one, name: DemoLT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
