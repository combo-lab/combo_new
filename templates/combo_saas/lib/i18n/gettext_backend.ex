defmodule ComboSaaS.I18n.GettextBackend do
  @moduledoc """
  Provides i18n support with a gettext-based API.

  It provides a set of macros for translations, for example:

      use Gettext, backend: ComboSaaS.I18n.GettextBackend

      # Simple translation
      gettext("Here is the string to translate")

      # Plural translation
      ngettext("Here is the string to translate",
               "Here are the strings to translate",
               3)

      # Domain-based translation
      dgettext("errors", "Here is the error message to translate")

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.

  ## Extract and merge templates

  ```console
  $ mix i18n.gettext.merge
  ```

  ## Add new locale

  ```console
  $ mix i18n.gettext.add_locale zh
  ```

  Get more details at
  <https://github.com/elixir-gettext/gettext/blob/da71fb6d2c9e0a607376b5bb945c80ffc9e18b9b/README.md#workflow>.

  """

  alias ComboSaaS.I18n.Config
  require ComboSaaS.I18n.Config

  # credo:disable-for-next-line Credo.Check.Readability.StrictModuleLayout
  use Gettext.Backend,
    otp_app: :combo_saas,
    priv: "priv/i18n/gettext",
    allowed_locales: Config.locales(),
    default_locale: Config.default_locale()

  @type locale() :: String.t()

  @doc false
  @spec put_locale(locale()) :: locale()
  def put_locale(locale) do
    Gettext.put_locale(__MODULE__, locale)
    locale
  end

  @doc false
  @spec get_locale :: locale()
  def get_locale do
    Gettext.get_locale(__MODULE__)
  end

  @doc false
  @spec translate_error({String.t(), keyword()}) :: String.t()
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(__MODULE__, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(__MODULE__, "errors", msg, opts)
    end
  end
end
