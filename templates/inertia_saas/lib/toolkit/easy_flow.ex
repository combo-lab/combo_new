defmodule InertiaSaaS.Toolkit.EasyFlow do
  @moduledoc """
  Provides tools for `with` expression.

  `with` expression is a great tool for assembling business logic. For example:

      def edit_post(post_id, editor, title, body) do
        with {:ok, post} <- fetch_post(post_id),
             :ok <- validate_post_editor(post, editor) do
          update_post(post, title, body)
        end
      end

      defp fetch_post(post_id) do
        case Repo.get(Post, post_id) do
          nil -> {:error, :not_found}
          post -> {:ok, post}
        end
      end

      defp validate_post_editor(post, editor) do
        if post.author_id == editor.id,
          do: :ok,
          else: {:error, :unauthorized}
      end

  But, above code has one problem. Although above private functions are small
  and easy to read, they are introduced only for a mechanical reason - normalizing
  the return values of functions into a shape that can be used in `with`
  expression. Because of these private functions, the business logic becomes
  too fragmented, forcing the reader to excessively jump back and forth.

  With tools provided by this module, above example can be rewritten as:

      def edit_post(post_id, editor, title, body) do
        with {:ok, post} <- if_else(Repo.get(Post, post_id), :not_found),
             {:ok, _authorized} <- if_else(post.author_id == editor.id, :unauthorized) do
          update_post(post, title, body)
        end
      end

  Now, the business logic is as concise as the previous version, but it doesn't
  require creating additional private functions.

  Consequently, an intuitive flow lies in the code.

  ## Usage

      import #{inspect(__MODULE__)}
      # Then, call the functions provided by this module directly.
      
  """

  @type value :: any()
  @type reason :: any()

  @doc """
  If `value` is a truthy value, it returns `:ok`.
  Otherwise, it returns `:error`.
  """
  @spec if_else(value()) :: :ok | :error
  def if_else(value) do
    if value,
      do: :ok,
      else: :error
  end

  @doc """
  If `value` is a truthy value, it returns `:ok`.
  Otherwise, it returns `{:error, reason}`.
  """
  @spec if_else(value(), reason()) :: :ok | {:error, reason()}
  def if_else(value, reason) do
    if value,
      do: :ok,
      else: {:error, reason}
  end

  @doc """
  If `value` is a truthy value, it returns `{:ok, value}`.
  Otherwise, it returns `:error`.
  """
  @spec vif_else(value()) :: {:ok, value()} | :error
  def vif_else(value) do
    if value,
      do: {:ok, value},
      else: :error
  end

  @doc """
  If `value` is a truthy value, it returns `{:ok, value}`.
  Otherwise, it returns `{:error, reason}`.
  """
  @spec vif_else(value(), reason()) :: {:ok, value()} | {:error, reason()}
  def vif_else(value, reason) do
    if value,
      do: {:ok, value},
      else: {:error, reason}
  end

  @doc """
  If `value` is `:ok` or `{:ok, _}`, it returns `value` itself.
  Otherwise, it returns `:error`.
  """
  @spec ok_else(:ok) :: :ok
  @spec ok_else({:ok, any()}) :: {:ok, any()}
  @spec ok_else(value()) :: :error
  def ok_else(:ok), do: :ok
  def ok_else({:ok, _} = value), do: value
  def ok_else(_value), do: :error

  @doc """
  If `value` is `:ok` or `{:ok, _}`, it returns `value` itself.
  Otherwise, it returns `{:error, reason}`.
  """
  @spec ok_else(:ok, reason()) :: :ok
  @spec ok_else({:ok, any()}, reason()) :: {:ok, any()}
  @spec ok_else(value(), reason()) :: {:error, reason()}
  def ok_else(:ok = value, _reason), do: value
  def ok_else({:ok, _} = value, _reason), do: value
  def ok_else(_value, reason), do: {:error, reason}
end
