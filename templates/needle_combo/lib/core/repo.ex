defmodule NeedleCombo.Core.Repo do
  use Ecto.Repo,
    otp_app: :needle_combo,
    adapter: Ecto.Adapters.Postgres
end
