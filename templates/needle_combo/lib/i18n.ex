defmodule NeedleCombo.I18n do
  @moduledoc """
  A module providing Internationalization support.

  Commonly used packages:

    * [cldr](https://github.com/elixir-cldr/cldr)
    * [gettext](https://github.com/elixir-gettext/gettext)
    * ...

  ## Locales

  The names of locales follows [IETF BCP 47](https://tools.ietf.org/html/bcp47).

  ## Change locale

  When an Elixir process want to change the locale of all backends. It
  should use `put_locale/1` provided by current module instead of the
  `Gettext.put_locale/1` or `Cldr.put_locale/1`.

  """

  alias NeedleCombo.I18n.Config
  alias NeedleCombo.I18n.Cldr
  alias NeedleCombo.I18n.Gettext

  @doc """
  Gets the default locale.
  """
  def get_default_locale(), do: Config.default_locale()

  @doc """
  Gets supported locales.
  """
  def get_supported_locales(), do: Config.locales()

  @doc """
  Changes the locale of current process.
  """
  def put_locale(locale) when is_binary(locale) do
    locale = sanitize_locale(locale)
    put_trusted_locale(locale)
  end

  @doc """
  Changes the locale of current process.

  Like `put_locale/1`, but it treats give locale as trusted and doesn't
  sanitize it  anymore.

  It's often used with `sanitize_locale/1`.

  """
  def put_trusted_locale(locale) when is_binary(locale) do
    Gettext.put_locale(locale)
    Cldr.put_locale(locale)

    :ok
  end

  @doc """
  Gets the locale of current process.
  """
  def get_locale() do
    Gettext.get_locale()
  end

  @doc """
  Sanitizes an arbitrary locale to a known locale.
  """
  def sanitize_locale(locale) do
    case locale do
      # explicit matching on supported locale
      locale when locale in ["en", "zh-Hans"] ->
        locale

      # fuzzy matching on english related locale
      "en-" <> _ ->
        "en"

      # fuzzy matching on zh-Hans related locale
      "zh-" <> _ ->
        "zh-Hans"

      # fallback for unsupported locales, such as ja-Jpan, ko-Kore
      _ ->
        "en"
    end
  end
end
