defmodule NeedleComboAdminWeb.Layouts do
  use NeedleComboAdminWeb, :html

  embed_templates "layouts/*"

  defp get_base_path() do
    :needle_combo
    |> Application.get_env(NeedleComboAdminWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
