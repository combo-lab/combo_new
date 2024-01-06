defmodule NeedleCombo.UserWeb.Layouts do
  use NeedleCombo.UserWeb, :html

  embed_templates "layouts/*"

  defp get_base_path() do
    :needle_combo
    |> Application.get_env(NeedleCombo.UserWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
