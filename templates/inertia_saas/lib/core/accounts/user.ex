defmodule InertiaSaaS.Core.Accounts.User do
  @moduledoc false

  use InertiaSaaS.Core.Schema

  schema "accounts_users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_hash, :string, redact: true

    timestamps()
  end
end
