defmodule NeedleCombo.I18n do
  @moduledoc """
  Provides i18n support.

  Commonly used packages:

    * [cldr](https://github.com/elixir-cldr/cldr)
    * [gettext](https://github.com/elixir-gettext/gettext)
    * ...

  ## Locales

  The names of locales follows [IETF BCP 47](https://tools.ietf.org/html/bcp47).

  ## Change locale

  When an Elixir process want to change the locale of all backends. It
  should use `put_locale/1` provided by this module instead of the
  `Gettext.put_locale/1`, `Cldr.put_locale/1`, etc.

  """

  require NeedleCombo.I18n.Config
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
  def get_supported_locales(), do: Config.supported_locales()

  @doc """
  Changes the locale of current process.
  """
  def put_locale(locale) when is_binary(locale) do
    locale = cast_locale(locale)
    put_trusted_locale(locale)
  end

  @doc """
  Changes the locale of current process.

  Like `put_locale/1`, but it treats give locale as trusted and doesn't
  casted it anymore.

  It's often used with `cast_locale/1`.

  """
  def put_trusted_locale(locale) when is_binary(locale) do
    Gettext.put_locale(locale)
    Cldr.put_locale(locale)

    put_process_locale(locale)

    :ok
  end

  @doc """
  Gets the locale of current process.
  """
  def get_locale(), do: get_process_locale()

  @doc """
  Casts an arbitrary locale to a known locale.
  """
  def cast_locale(locale) do
    case locale do
      # explicit matching on supported locale
      locale when locale in Config.supported_locales() ->
        locale

      # fuzzy matching on en related locale
      "en-" <> _ ->
        "en"

      # add more patterns here...
      #
      # "zh-" <> _ ->
      #   "zh-Hans"

      # fallback locale for unsupported locales, such as ja-Jpan, ko-Kore, etc.
      _ ->
        "en"
    end
  end

  @process_locale_key __MODULE__
                      |> Module.split()
                      |> Enum.map(&Macro.underscore/1)
                      |> Enum.join("_")
                      |> String.to_atom()
  defp put_process_locale(value), do: Process.put(@process_locale_key, value)
  defp get_process_locale(), do: Process.get(@process_locale_key, Config.default_locale())
end
