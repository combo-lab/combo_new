defmodule LiveSaaS.Core.Accounts.User do
  @moduledoc false

  use LiveSaaS.Core.Schema

  schema "accounts_users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_hash, :string, redact: true

    timestamps()
  end
end
