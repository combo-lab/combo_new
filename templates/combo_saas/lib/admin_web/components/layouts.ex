defmodule ComboSaaS.AdminWeb.Layouts do
  use ComboSaaS.AdminWeb, :html

  embed_templates "layouts/*"

  defp get_base_path do
    :combo_saas
    |> Application.get_env(ComboSaaS.AdminWeb.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
