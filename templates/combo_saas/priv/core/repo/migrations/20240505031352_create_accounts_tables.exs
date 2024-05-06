defmodule ComboSaaS.Core.Repo.Migrations.CreateAccountsTables do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :citext, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:accounts_users, [:email])

    create table(:accounts_no_user_tokens) do
      add :sent_to, :string, null: false
      add :type, :string, null: false
      add :token_hash, :binary, null: false
      add :payload, :map, null: false, default: %{}

      timestamps(updated_at: false)
    end

    create unique_index(:accounts_no_user_tokens, [:sent_to, :type, :token_hash])

    create table(:accounts_user_tokens) do
      add :user_id, references(:accounts_users, on_delete: :delete_all), null: false
      add :sent_to, :string, null: false
      add :type, :string, null: false
      add :token_hash, :binary, null: false
      add :payload, :map, null: false, default: %{}

      timestamps(updated_at: false)
    end

    create index(:accounts_user_tokens, [:user_id])
    create unique_index(:accounts_user_tokens, [:user_id, :sent_to, :type, :token_hash])

    create table(:accounts_user_session_tokens) do
      add :user_id, references(:accounts_users, on_delete: :delete_all), null: false
      add :token_hash, :binary, null: false
      add :meta, :map, null: false, default: %{}

      timestamps(updated_at: false)
    end

    create index(:accounts_user_session_tokens, [:user_id])
    create unique_index(:accounts_user_session_tokens, [:token_hash])
  end
end
