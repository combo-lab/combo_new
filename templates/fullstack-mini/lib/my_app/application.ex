defmodule MyApp.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    if stacktrace_depth = Application.get_env(:my_app, :stacktrace_depth, nil) do
      :erlang.system_flag(:backtrace_depth, stacktrace_depth)
    end

    children = [
      MyApp.PubSub,
      MyApp.Core.Supervisor,
      MyApp.Web.Supervisor
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
