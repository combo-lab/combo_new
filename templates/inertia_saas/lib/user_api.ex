# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule InertiaSaaS.UserAPI do
  @moduledoc """
  The entrypoint for defining the web interface, such
  as controllers, components, channels, and so on.

  This can be used in the application as:

      use InertiaSaaS.UserAPI, :router
      use InertiaSaaS.UserAPI, :controller

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  use Boundary,
    deps: [
      Phoenix,
      Ecto.Changeset,
      InertiaSaaS.I18n,
      InertiaSaaS.Core
    ],
    exports: [
      Supervisor
    ]

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:json],
        layouts: []

      import Plug.Conn

      unquote(verified_routes())

      action_fallback InertiaSaaS.UserAPI.FallbackController
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: InertiaSaaS.UserAPI.Endpoint,
        router: InertiaSaaS.UserAPI.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate router, controller, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
