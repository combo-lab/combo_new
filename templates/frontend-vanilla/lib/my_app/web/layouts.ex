defmodule MyApp.Web.Layouts do
  use MyApp.Web, :html

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
    ~CE"""
    <header>
      <div>
        <div>
          <a href="/">
            Home
          </a>
        </div>
        <div>
          <a href="https://hexdocs.pm/combo/">
            Get Started <span aria-hidden="true">&rarr;</span>
          </a>
        </div>
      </div>
    </header>
    <main>
      <div>
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end
end
