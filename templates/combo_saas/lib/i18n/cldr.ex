defmodule ComboSaaS.I18n.Cldr do
  @moduledoc """
  A backend module that hosts Cldr configuration and public API.
  """

  alias ComboSaaS.I18n.Config
  require ComboSaaS.I18n.Config

  # credo:disable-for-next-line Credo.Check.Readability.StrictModuleLayout
  use Cldr,
    otp_app: :combo_saas,
    data_dir: "priv/i18n/cldr",
    locales: Config.locales(),
    default_locale: Config.default_locale(),
    providers: []
end
