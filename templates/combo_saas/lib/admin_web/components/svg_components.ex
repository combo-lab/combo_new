defmodule ComboSaaS.AdminWeb.SvgComponents do
  @moduledoc """
  Provides SVG components.

  In some cases, we want to embed SVG data into web pages instead of asking
  the browser to make additional requests to servers. This helps to:

    * load web pages faster
    * avoid flash of loading SVG files
    * ...

  This module compiles the SVG files located at `assets/admin_web/svg`, and provides
  components to access them.

  See `CozySVG` for more details.

  ## Examples

      # Put SVG files into assets/admin_web/svg:
      #
      # assets/admin_web/svg
      # ├── logo.svg
      # └── social-media
      #     ├── x.svg
      #     └── facebook.svg
      #

      <.svg key="logo" class="w-6 h-auto" />
      <.svg key="social-media/x" class="w-6 h-auto" />

  """

  defmodule CompiledSVG do
    use CozySVG.QuickWrapper, root: Path.expand("../../../assets/admin_web/svg", __DIR__)
  end

  use Phoenix.Component
  import Phoenix.HTML, only: [raw: 1]

  attr :key, :string, required: true, doc: "The key for SVG file."
  attr :rest, :global, doc: "Additional attributes to add to the <svg> tag."

  def svg(assigns) do
    ~H"""
    <%= raw(CompiledSVG.render(@key, @rest)) %>
    """
  end
end
