# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboLite.UserWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ComboLite.UserWeb, :controller
      use ComboLite.UserWeb, :html

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
      ComboLite.Telemetry,
      ComboLite.I18n,
      ComboLite.Core
    ],
    exports: [
      Supervisor
    ]

  def static_paths, do: ~w(robots.txt favicon.ico icons images assets)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
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
        formats: [:html],
        layouts: [html: {ComboLite.UserWeb.Layouts, :app}]

      use ComboLite.I18n, :gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ComboLite.UserWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      unquote(component_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      unquote(component_helpers())

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp component_helpers do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      # a helper function for emulating :default option for slot attrs
      defp default(assigns, key, default \\ nil) do
        Map.get(assigns, key, default)
      end

      # a helper function for emulating :global type for slot attrs
      defp rest(assigns, exclude \\ []) when is_list(exclude) do
        Phoenix.Component.assigns_to_attributes(assigns, exclude)
      end
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # UI components
      import ComboLite.UserWeb.BaseComponents
      import ComboLite.UserWeb.CoreComponents

      # i18n support
      use ComboLite.I18n, :gettext
      alias ComboLite.I18n

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ComboLite.UserWeb.Endpoint,
        router: ComboLite.UserWeb.Router,
        statics: ComboLite.UserWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller, live_view, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
