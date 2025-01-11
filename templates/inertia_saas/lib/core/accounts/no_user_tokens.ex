defmodule InertiaSaaS.Core.Accounts.NoUserTokens do
  @moduledoc false

  import Ecto.Query
  alias InertiaSaaS.Toolkit.EasyToken
  alias InertiaSaaS.Core.Repo
  alias InertiaSaaS.Core.Accounts.NoUserToken

  @type sent_to :: String.t()
  @type payload :: map()
  @type token :: String.t()

  @spec create_token!(sent_to(), NoUserToken.type(), payload()) :: token()
  def create_token!(sent_to, type, payload \\ %{}) do
    format = NoUserToken.format(type)
    {token, token_hash} = EasyToken.generate(format)

    Repo.insert!(
      %NoUserToken{
        sent_to: sent_to,
        type: type,
        token_hash: token_hash,
        payload: payload
      },
      conflict_target: [:sent_to, :type, :token_hash],
      on_conflict: {:replace_all_except, [:id]}
    )

    token
  end

  @spec consume_token(sent_to(), NoUserToken.type(), token()) :: :ok | :error
  def consume_token(sent_to, type, token) do
    format = NoUserToken.format(type)

    with {:ok, token_hash} <- EasyToken.hash(format, token),
         {1, nil} <-
           Repo.delete_all(
             valid_tokens_query(
               sent_to: sent_to,
               type: type,
               token_hash: token_hash
             )
           ),
         do: :ok,
         else: (_ -> :error)
  end

  @spec delete_tokens(sent_to()) :: :ok
  def delete_tokens(sent_to) do
    Repo.delete_all(valid_tokens_query(sent_to: sent_to))
    :ok
  end

  @spec delete_tokens(sent_to(), NoUserToken.type()) :: :ok
  def delete_tokens(sent_to, type) do
    Repo.delete_all(valid_tokens_query(sent_to: sent_to, type: type))
    :ok
  end

  @spec cleanup_tokens() :: :ok
  def cleanup_tokens do
    Repo.delete_all(invalid_tokens_query())
    :ok
  end

  defp valid_tokens_query, do: filter_tokens(&unexpired_filter/1)
  defp valid_tokens_query(criteria), do: where(valid_tokens_query(), ^criteria)

  defp invalid_tokens_query, do: filter_tokens(&expired_filter/1)

  defp unexpired_filter(type_def) do
    dynamic(
      [no_user_token],
      no_user_token.inserted_at >= ago(^type_def.ttl_in_minutes, "minute")
    )
  end

  defp expired_filter(type_def) do
    dynamic(not (^unexpired_filter(type_def)))
  end

  defp filter_tokens(filter_fun) do
    filter =
      Enum.reduce(
        NoUserToken.type_defs(),
        dynamic(false),
        fn {type, type_def}, dynamic ->
          dynamic(
            [no_user_token],
            ^dynamic or (no_user_token.type == ^type and ^filter_fun.(type_def))
          )
        end
      )

    where(NoUserToken, ^filter)
  end
end
