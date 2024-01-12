defmodule ComboLite.UserWeb.Layouts do
  use ComboLite.UserWeb, :html

  embed_templates "layouts/*"

  defp get_base_path do
    :combo_lite
    |> Application.get_env(ComboLite.UserWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
