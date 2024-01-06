defmodule ComboLite.Repo do
  use Ecto.Repo,
    otp_app: :combo_lite,
    adapter: Ecto.Adapters.Postgres
end
