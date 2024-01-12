defmodule ComboSaaS.I18n.Cldr do
  @moduledoc """
  A backend module that hosts Cldr configuration and public API.
  """

  require ComboSaaS.I18n.Config

  # credo:disable-for-next-line Credo.Check.Readability.StrictModuleLayout
  use Cldr,
    otp_app: :combo_saas,
    data_dir: "priv/i18n/cldr",
    locales: ComboSaaS.I18n.Config.supported_locales(),
    default_locale: ComboSaaS.I18n.Config.default_locale(),
    providers: []
end
