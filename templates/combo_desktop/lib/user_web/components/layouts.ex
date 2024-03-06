defmodule ComboDesktop.UserWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ComboDesktop.UserWeb, :controller` and
  `use ComboDesktop.UserWeb, :live_view`.
  """
  use ComboDesktop.UserWeb, :html

  embed_templates "layouts/*"

  defp get_base_path do
    :combo_desktop
    |> Application.get_env(ComboDesktop.UserWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
