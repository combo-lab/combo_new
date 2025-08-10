defmodule DemoLT.Core.Accounts.UserSessionToken do
  @moduledoc false

  use DemoLT.Core.Schema
  alias DemoLT.Core.Accounts.User

  # Since expired session token requires user to log in again, in order to
  # minimize the impact on users' continuous usage experience as much as
  # possible, it's important to set the ttl long enough. Default to
  # `60 * 24 * 60`, which means 60 days.
  @ttl_in_minutes 60 * 24 * 60

  schema "accounts_user_session_tokens" do
    belongs_to :user, User
    field :token_hash, :binary
    field :meta, :map

    timestamps(updated_at: false)
  end

  @spec ttl_in_minutes() :: pos_integer()
  def ttl_in_minutes, do: @ttl_in_minutes
end
