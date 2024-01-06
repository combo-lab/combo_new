defmodule NeedleCombo.I18n.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  It provides a set of macros for translations, for example:

      import NeedleCombo.I18n.Gettext

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

  Get more details at
  <https://github.com/elixir-gettext/gettext/blob/da71fb6d2c9e0a607376b5bb945c80ffc9e18b9b/README.md#workflow>.

  """

  use Gettext,
    otp_app: :needle_combo,
    priv: "priv/i18n/gettext",
    allowed_locales: NeedleCombo.I18n.Config.locales(),
    default_locale: NeedleCombo.I18n.Config.default_locale()

  def put_locale(locale) do
    Gettext.put_locale(__MODULE__, locale)
  end

  def get_locale() do
    Gettext.get_locale(__MODULE__)
  end
end
