defmodule ComboSaaS.Core.Repo do
  use Ecto.Repo,
    otp_app: :combo_saas,
    adapter: Ecto.Adapters.Postgres

  @impl Ecto.Repo
  def init(_context, config) do
    config =
      config
      |> deep_merge(
        priv: "priv/core/repo",
        migration_primary_key: [name: :id, type: :binary_id],
        migration_timestamps: [type: :utc_datetime_usec]
      )

    {:ok, config}
  end

  defp deep_merge(config1, config2) do
    # Config.Reader.merge requires a top-level format of `key: config`, so
    # we're using the `:opts` key.
    [opts: config1]
    |> Config.Reader.merge(opts: config2)
    |> Keyword.fetch!(:opts)
  end
end
