# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserWeb.BaseComponents do
  @moduledoc """
  Provides base UI components.

  The components in this module should be style-irrelevant.
  """

  use ComboSaaS.UserWeb, :component
  import Phoenix.HTML, only: [raw: 1]

  @doc """
  Renders an icon.

  Currently, this component only supports limited sets of icons:

    * [Heroicon](https://heroicons.com)

  But, it can be extended to support more icons.

  ## Heroicon

  When using icons provided by Heroicon, the `name` attr should be prefixed
  by `hero-`.

  Heroicons come in four styles – outline, solid, micro and mini. By default,
  the outline style is used. You can specify the style by using following
  suffix:

    * `-outline`
    * `-solid`
    * `-micro`
    * `-mini`

  You can also customize the size and colors of the icons by setting width,
  height, and background color classes.

  Heroicons are extracted from the `node_modules/heroicons` directory and
  bundled into CSS file by the plugin in `assets/tailwind.config.js`.

  ### Examples

      <.icon name="hero-arrow-path" />
      <.icon name="hero-x-mark-solid" class="ml-1 w-3 h-3 animate-spin" />

  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  defmodule CompiledSVG do
    use CozySVG.QuickWrapper, root: Path.expand("../../../assets/user_web/svg", __DIR__)
  end

  @doc """
  Renders an SVG file.

  In some cases, we want to embed SVG data into web pages instead of asking
  the browser to make additional requests to servers. This helps to:

    * load web pages faster
    * avoid flash of loading SVG files
    * ...

  This module compiles the SVG files located at `assets/user_web/svg`, and provides
  components to access them.

  See `CozySVG` for more details.

  ## Examples

      # Put SVG files into assets/user_web/svg:
      #
      # assets/user_web/svg
      # ├── logo.svg
      # └── social-media
      #     ├── x.svg
      #     └── facebook.svg
      #

      <.svg name="logo" class="w-6 h-auto" />
      <.svg name="social-media/x" class="w-6 h-auto" />

  """

  attr :name, :string, required: true, doc: "The name for SVG file."
  attr :rest, :global, doc: "Additional attributes to add to the <svg> tag."

  def svg(assigns) do
    ~H"""
    <%= raw(CompiledSVG.render!(@name, @rest)) %>
    """
  end

  @doc """
  Renders an external link.

  ## Examples

      <.external_link href="https://example.com" />
      <.external_link href="https://example.com" nofollow />

  """

  attr :href, :string, required: true
  attr :nofollow, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def external_link(assigns) do
    ~H"""
    <a
      rel={
        if(@nofollow,
          do: "noopener noreferrer nofollow",
          else: "noopener noreferrer"
        )
      }
      target="_blank"
      href={@href}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end
end
