defmodule ComboDesktop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Boundary,
    top_level?: true,
    deps: [
      ComboDesktop.PubSub,
      ComboDesktop.Core,
      ComboDesktop.UserWeb
    ]

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      ComboDesktop.PubSub,
      ComboDesktop.Core.Supervisor,
      ComboDesktop.UserWeb.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ComboDesktop.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
