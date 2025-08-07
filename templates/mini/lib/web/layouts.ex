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
    <header class="px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between border-b border-base-100 py-3 text-sm">
        <div class="flex items-center gap-4">
          <a href="/">
            Home
          </a>
          <p class="bg-brand-500/5 text-brand-500 rounded-full px-2 font-medium leading-6">
            v{Application.spec(:phoenix, :vsn)}
          </p>
        </div>
        <div class="flex items-center gap-4 font-semibold leading-6 text-base-900">
          <a
            href="https://hexdocs.pm/phoenix/overview.html"
            class="rounded-lg bg-base-100 px-2 py-1 hover:bg-base-200/80"
          >
            Get Started <span aria-hidden="true">&rarr;</span>
          </a>
        </div>
      </div>
    </header>
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl">
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
