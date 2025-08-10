defmodule DemoLT.Core.Accounts.UserTokens do
  @moduledoc false

  import Ecto.Query
  alias DemoLT.Toolkit.EasyToken
  alias DemoLT.Core.Repo
  alias DemoLT.Core.Accounts.User
  alias DemoLT.Core.Accounts.UserToken

  @type sent_to :: String.t()
  @type payload :: map()
  @type token :: String.t()

  @spec create_token!(User.t(), sent_to(), UserToken.type(), payload()) :: token()
  def create_token!(user, sent_to, type, payload \\ %{}) do
    format = UserToken.format(type)
    {token, token_hash} = EasyToken.generate(format)

    Repo.insert!(
      %UserToken{
        user_id: user.id,
        sent_to: sent_to,
        type: type,
        token_hash: token_hash,
        payload: payload
      },
      conflict_target: [:user_id, :sent_to, :type, :token_hash],
      on_conflict: {:replace_all_except, [:id]}
    )

    token
  end

  @spec consume_token(User.t(), sent_to(), UserToken.type(), token()) :: :ok | :error
  def consume_token(user, sent_to, type, token) do
    format = UserToken.format(type)

    with {:ok, token_hash} <- EasyToken.hash(format, token),
         {1, nil} <-
           Repo.delete_all(
             valid_tokens_query(
               user: user,
               sent_to: sent_to,
               type: type,
               token_hash: token_hash
             )
           ),
         do: :ok,
         else: (_ -> :error)
  end

  @spec delete_tokens(User.t()) :: :ok
  def delete_tokens(user) do
    Repo.delete_all(valid_tokens_query(user: user))
    :ok
  end

  @spec delete_tokens(User.t(), sent_to()) :: :ok
  def delete_tokens(user, sent_to) do
    Repo.delete_all(valid_tokens_query(user: user, sent_to: sent_to))
    :ok
  end

  @spec delete_tokens(User.t(), sent_to(), UserToken.type()) :: :ok
  def delete_tokens(user, sent_to, type) do
    Repo.delete_all(valid_tokens_query(user: user, sent_to: sent_to, type: type))
    :ok
  end

  @spec cleanup_tokens() :: :ok
  def cleanup_tokens do
    Repo.delete_all(invalid_tokens_query())
    :ok
  end

  defp valid_tokens_query, do: filter_tokens(&unexpired_filter/1)

  defp valid_tokens_query(criteria) do
    filter =
      Enum.map(criteria, fn
        {:user, user} -> {:user_id, user.id}
        {field, value} -> {field, value}
      end)

    where(valid_tokens_query(), ^filter)
  end

  defp invalid_tokens_query, do: filter_tokens(&expired_filter/1)

  defp unexpired_filter(type_def) do
    dynamic(
      [user_token],
      user_token.inserted_at >= ago(^type_def.ttl_in_minutes, "minute")
    )
  end

  defp expired_filter(type_def) do
    dynamic(not (^unexpired_filter(type_def)))
  end

  defp filter_tokens(filter_fun) do
    filter =
      Enum.reduce(
        UserToken.type_defs(),
        dynamic(false),
        fn {type, type_def}, dynamic ->
          dynamic(
            [user_token],
            ^dynamic or (user_token.type == ^type and ^filter_fun.(type_def))
          )
        end
      )

    where(UserToken, ^filter)
  end
end
