defmodule ComboLT.Web.Layouts do
  use ComboLT.Web, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main>
      <div>
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  defp get_base_path do
    :combo_lt
    |> Application.get_env(ComboLT.Web.Endpoint)
    |> get_in([:url, :path])
    |> then(&(&1 || ""))
    |> String.trim_trailing("/")
  end
end
