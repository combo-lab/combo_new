defmodule NeedleCombo.I18n.Cldr do
  @moduledoc """
  A backend module that hosts Cldr configuration and public API.
  """

  use Cldr,
    otp_app: :needle_combo,
    data_dir: "priv/i18n/cldr",
    locales: NeedleCombo.I18n.Config.locales(),
    default_locale: NeedleCombo.I18n.Config.default_locale(),
    providers: []
end
