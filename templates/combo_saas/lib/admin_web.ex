# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.AdminWeb do
  @moduledoc """
  The entrypoint for defining the web interface, such
  as controllers, components, channels, and so on.

  This can be used in the application as:

      use ComboSaaS.AdminWeb, :controller
      use ComboSaaS.AdminWeb, :html

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
      ComboSaaS.Telemetry,
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
        layouts: [html: {ComboSaaS.AdminWeb.Layouts, :app}]

      import Plug.Conn
      import ComboSaaS.I18n.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ComboSaaS.AdminWeb.Layouts, :app}

      unquote(html_helpers())
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
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # UI components
      import ComboSaaS.AdminWeb.CoreComponents
      import ComboSaaS.AdminWeb.SvgComponents

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
        endpoint: ComboSaaS.AdminWeb.Endpoint,
        router: ComboSaaS.AdminWeb.Router,
        statics: ComboSaaS.AdminWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
