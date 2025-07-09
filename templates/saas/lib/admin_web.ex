defmodule ComboLT.AdminWeb do
  @moduledoc """
  The entrypoint for defining the web interface, such
  as controllers, components, channels, and so on.

  This can be used in the application as:

      use ComboLT.AdminWeb, :controller
      use ComboLT.AdminWeb, :html

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
      ComboLT.I18n,
      ComboLT.Core
    ],
    exports: [
      Supervisor
    ]

  def static_paths, do: ~w(robots.txt favicon.ico build)

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
      use Phoenix.Controller, formats: [:html]

      use ComboLT.I18n, :gettext

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
      import ComboLT.AdminWeb.CoreComponents

      # Command modules used in templates
      alias ComboLT.AdminWeb.Layouts

      # i18n support
      use ComboLT.I18n, :gettext
      alias ComboLT.I18n

      # vite support
      use Combo.Vite.Component,
        endpoint: ComboLT.Endpoint,
        static_dir: {:combo_lt, "priv/admin_web/static"},
        ssr_out_dir: {:combo_lt, "priv/admin_web/ssr"}

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ComboLT.AdminWeb.Endpoint,
        router: ComboLT.AdminWeb.Router,
        statics: ComboLT.AdminWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller, live_view, etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
