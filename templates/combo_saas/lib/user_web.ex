# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserWeb do
  @moduledoc """
  The entrypoint for defining the web interface, such
  as controllers, components, channels, and so on.

  This can be used in the application as:

      use ComboSaaS.UserWeb, :controller
      use ComboSaaS.UserWeb, :html

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
      ComboSaaS.I18n,
      ComboSaaS.Core
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
        layouts: [html: {ComboSaaS.UserWeb.Layouts, :app}]

      import Plug.Conn
      import ComboSaaS.I18n.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ComboSaaS.UserWeb.Layouts, :app}

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
      import ComboSaaS.UserWeb.BaseComponents
      import ComboSaaS.UserWeb.CoreComponents

      # i18n helpers
      alias ComboSaaS.I18n
      import ComboSaaS.I18n.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ComboSaaS.UserWeb.Endpoint,
        router: ComboSaaS.UserWeb.Router,
        statics: ComboSaaS.UserWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller, live_view, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
