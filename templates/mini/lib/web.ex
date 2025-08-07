defmodule ComboLT.Web do
  @moduledoc """
  Defines the web interface, such as controllers, components, channels,
  and so on.

  This can be used in the application as:

      use ComboLT.Web, :controller
      use ComboLT.Web, :html

  The definitions below will be executed for every controller, component, etc,
  so keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below. Instead, define
  additional modules and import those modules here.
  """

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def static_paths, do: ~w(robots.txt favicon.ico assets)

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
      use Phoenix.Controller, formats: [:html, :json]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def component do
    quote do
      unquote(component_helpers())
    end
  end

  def html do
    quote do
      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
      unquote(component_helpers())
    end
  end

  defp component_helpers do
    quote do
      use Phoenix.Component
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Common modules used in templates
      alias ComboLT.Web.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ComboLT.Web.Endpoint,
        router: ComboLT.Web.Router,
        statics: ComboLT.Web.static_paths()
    end
  end
end
