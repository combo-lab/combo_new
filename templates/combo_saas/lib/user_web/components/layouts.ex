defmodule ComboSaaS.UserWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ComboSaaS.UserWeb, :controller` and
  `use ComboSaaS.UserWeb, :live_view`.
  """
  use ComboSaaS.UserWeb, :html

  embed_templates "layouts/*"

  defp get_base_path do
    :combo_saas
    |> Application.get_env(ComboSaaS.UserWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
