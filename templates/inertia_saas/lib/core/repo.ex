defmodule LiveSaaS.Core.Repo do
  use Ecto.Repo,
    otp_app: :live_saas,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Runs the given function inside a transaction.

  This function is a wrapper around `Repo.transaction`, with the following differences:

  * It accepts only a lambda of arity 0 or 1. (It doesn't work with `Ecto.Multi`)
  * If the lambda returns `:ok` or `{:ok, result}`, the transaction is committed.
  * If the lambda returns `:error` or `{:error, reason}`, the transaction is rolled back.
  * If the lambda returns any other kind of result, an exception is raised, and the transaction is rolled back.
  * The result of `transact` is the value returned by the lambda.

  This function accepts the same options as `Repo.transaction/2`.

  ## Examples

      Repo.transact(fn ->
        with {:ok, post} <- store_post_record(post, title, body),
             :ok <- create_notifications(post),
             do: {:ok, post}
      end)

  ## Notes

  This code is originally written by
  [Saša Jurić](https://github.com/sasa1977/mix_phx_alt/blob/d33a67fd6b2fa0ace5b6206487e774ef7a22ce5a/lib/core/repo.ex#L6).

  """
  @spec transact((-> result) | (module -> result), Keyword.t()) :: result
        when result: :ok | {:ok, any} | :error | {:error, any}
  def transact(fun, opts \\ []) do
    transaction_result =
      transaction(
        fn repo ->
          lambda_result =
            case Function.info(fun, :arity) do
              {:arity, 0} -> fun.()
              {:arity, 1} -> fun.(repo)
            end

          case lambda_result do
            :ok -> {__MODULE__, :transact, :ok}
            :error -> rollback({__MODULE__, :transact, :error})
            {:ok, result} -> result
            {:error, reason} -> rollback(reason)
          end
        end,
        opts
      )

    with {outcome, {__MODULE__, :transact, outcome}}
         when outcome in [:ok, :error] <- transaction_result,
         do: outcome
  end
end
