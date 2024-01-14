defmodule ComboSaaS.Core.Repo do
  use Ecto.Repo,
    otp_app: :combo_saas,
    adapter: Ecto.Adapters.Postgres
end
