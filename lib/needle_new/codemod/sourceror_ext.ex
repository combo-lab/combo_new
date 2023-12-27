defmodule NeedleNew.Codemod.SourcerorExt do
  @moduledoc """
  The Extensions of Sourceror.
  """

  @line_fields ~w[line closing do end end_of_expression leading_comments trailing_comments]a

  @doc """
  Convert an ast into a block if it's not one.
  """
  def to_block({:__block__, _, _} = ast), do: ast
  def to_block(ast), do: {:__block__, [trailing_comments: [], leading_comments: []], [ast]}

  @doc """
  Shifts the line numbers of the node or metadata by the given `line_correction`.

  > This is an improved version of original `correct_lines/3`.
  > I should contribute it back to Sourceror.
  """
  def correct_lines(meta, line_correction, opts \\ [])

  def correct_lines({_form, _meta, _args} = ast, line_correction, opts) do
    Sourceror.postwalk(ast, fn
      {form, meta, args}, state ->
        ast = {form, correct_lines(meta, line_correction, opts), args}
        {ast, state}

      ast, state ->
        {ast, state}
    end)
  end

  def correct_lines(meta, line_correction, opts) when is_list(meta) do
    skip = Keyword.get(opts, :skip, [])

    to_correct = @line_fields -- skip
    corrections = Enum.map(to_correct, &correct_line(meta, &1, line_correction))

    Enum.reduce(corrections, meta, fn correction, meta ->
      Keyword.merge(meta, correction)
    end)
  end

  defp correct_line(meta, :line = key, line_correction) do
    if line = Keyword.get(meta, key) do
      value = line + line_correction
      [{key, value}]
    else
      []
    end
  end

  defp correct_line(meta, key, line_correction)
       when key in [:leading_comments, :trailing_comments] do
    if comments = Keyword.get(meta, key) do
      value =
        Enum.map(comments, fn comment ->
          Map.update!(comment, :line, &(&1 + line_correction))
        end)

      [{key, value}]
    else
      []
    end
  end

  defp correct_line(meta, key, line_correction) do
    if value = Keyword.get(meta, key) do
      value =
        if line = value[:line] do
          put_in(value, [:line], line + line_correction)
        else
          value
        end

      [{key, value}]
    else
      []
    end
  end
end
