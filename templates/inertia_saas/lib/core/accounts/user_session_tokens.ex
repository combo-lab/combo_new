defmodule InertiaSaaS.Core.Accounts.UserSessionTokens do
  @moduledoc false

  import Ecto.Query
  import InertiaSaaS.Toolkit.EasyFlow
  alias InertiaSaaS.Toolkit.EasyToken
  alias InertiaSaaS.Core.Repo
  alias InertiaSaaS.Core.Accounts.User
  alias InertiaSaaS.Core.Accounts.UserSessionToken

  @token_format {:binary, size: 32}

  @type meta :: map()
  @type token :: String.t()

  @spec create_token!(User.t(), meta()) :: token()
  def create_token!(user, meta \\ %{}) do
    {token, token_hash} = EasyToken.generate(@token_format)

    # Do not use upsert here. Otherwise, a token conflict could allow one user
    # to access another user's resources.
    # If a conflict does occur, then let it crash.
    Repo.insert!(%UserSessionToken{
      user_id: user.id,
      token_hash: token_hash,
      meta: meta
    })

    token
  end

  @spec fetch_token(token()) :: {:ok, UserSessionToken.t()} | :error
  def fetch_token(token) do
    with {:ok, token_hash} <- EasyToken.hash(@token_format, token),
         user_session_token = Repo.one(valid_tokens_query(token_hash: token_hash)),
         :ok <- if_else(user_session_token),
         do: {:ok, user_session_token},
         else: (_ -> :error)
  end

  @spec delete_token(token()) :: :ok
  def delete_token(token) do
    with {:ok, token_hash} <- EasyToken.hash(@token_format, token) do
      Repo.delete_all(valid_tokens_query(token_hash: token_hash))
    end

    :ok
  end

  @spec delete_tokens(User.t()) :: :ok
  def delete_tokens(user) do
    Repo.delete_all(valid_tokens_query(user: user))
    :ok
  end

  @spec delete_tokens(User.t(), except: token()) :: :ok
  def delete_tokens(user, except: token) do
    with {:ok, token_hash} <- EasyToken.hash(@token_format, token) do
      valid_tokens_query(user: user)
      |> where([user_session_token], user_session_token.token_hash != ^token_hash)
      |> Repo.delete_all()
    end

    :ok
  end

  # It helps to remove old tokens when you want to keep the number of valid
  # tokens under a fixed limit.
  @spec rotate_tokens(User.t()) :: :ok
  def rotate_tokens(%User{} = user) do
    preserved_limit = 5

    preserved_token_ids =
      valid_tokens_query(user: user)
      |> order_by([token], desc: token.inserted_at)
      |> limit([_], ^preserved_limit)
      |> select([token], token.id)

    {_, _} =
      valid_tokens_query(user: user)
      |> where([token], token.id not in subquery(preserved_token_ids))
      |> Repo.delete_all()

    :ok
  end

  @spec cleanup_tokens() :: :ok
  def cleanup_tokens do
    Repo.delete_all(invalid_token_query())
    :ok
  end

  defp valid_tokens_query, do: where(UserSessionToken, ^unexpired_filter())

  defp valid_tokens_query(criteria) do
    filter =
      Enum.map(criteria, fn
        {:user, user} -> {:user_id, user.id}
        {field, value} -> {field, value}
      end)

    where(valid_tokens_query(), ^filter)
  end

  defp invalid_token_query, do: where(UserSessionToken, ^expired_filter())

  defp unexpired_filter do
    dynamic(
      [user_session_token],
      user_session_token.inserted_at >= ago(^UserSessionToken.ttl_in_minutes(), "minute")
    )
  end

  defp expired_filter do
    dynamic(not (^unexpired_filter()))
  end
end
