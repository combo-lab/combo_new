defmodule ComboLite.I18n do
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
  `Gettext.put_locale/1`, etc.

  """

  use Boundary,
    deps: [],
    exports: [
      Gettext
    ]

  alias ComboLite.I18n.Config
  alias ComboLite.I18n.Gettext
  require ComboLite.I18n.Config

  @type locale :: String.t()
  @type locales :: [locale()]

  @doc """
  Returns supported locales.
  """
  @spec locales :: locales()
  def locales, do: Config.locales()

  @doc """
  Returns the default locale.
  """
  @spec default_locale :: locale()
  def default_locale, do: Config.default_locale()

  @doc """
  Changes the locale of current process.
  """
  @spec put_locale(locale()) :: :ok
  def put_locale(locale) when is_binary(locale) do
    locale = cast_locale(locale)
    put_trusted_locale(locale)
  end

  @doc """
  Changes the locale of current process.

  Like `put_locale/1`, but it treats give locale as trusted and doesn't
  cast it anymore.

  It's often used with `cast_locale/1`.

  """
  @spec put_trusted_locale(locale()) :: :ok
  def put_trusted_locale(locale) when is_binary(locale) do
    Gettext.put_locale(locale)

    put_process_locale(locale)

    :ok
  end

  @doc """
  Gets the locale of current process.
  """
  @spec get_locale :: locale()
  def get_locale, do: get_process_locale()

  @doc """
  Casts an arbitrary locale to a known locale.
  """
  @spec cast_locale(String.t()) :: locale()
  def cast_locale(locale) do
    case locale do
      # explicit matching on supported locale
      locale when locale in Config.locales() ->
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
                      |> Enum.map_join("_", &Macro.underscore/1)
                      |> String.to_atom()
  defp put_process_locale(value), do: Process.put(@process_locale_key, value)
  defp get_process_locale, do: Process.get(@process_locale_key, Config.default_locale())
end
