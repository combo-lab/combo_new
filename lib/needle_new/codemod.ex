defmodule NeedleNew.Codemod do
  alias __MODULE__.SourcerorExt

  @doc """
  Injects new deps into the body of `deps/0` private function of source.
  """
  def inject_deps(source, new_source) when is_binary(new_source) do
    source
    |> Sourceror.parse_string!()
    |> Sourceror.postwalk(fn
      {:defp, meta, [{:deps, _, _} = fun, body]}, state ->
        [{{_, _, [:do]}, do_block_ast}] = body
        {:__block__, block_meta, [deps]} = do_block_ast

        new_deps_line =
          case List.last(deps) do
            {_, meta, _} ->
              meta[:line] || block_meta[:line]

            _ ->
              block_meta[:line]
          end + 1

        {:__block__, _block_meta, [new_deps]} =
          new_source
          |> Sourceror.parse_string!()
          |> add_extra_leading_comment_eol()
          |> SourcerorExt.correct_lines(new_deps_line)

        deps = deps ++ new_deps

        ast = {:defp, meta, [fun, [do: {:__block__, block_meta, [deps]}]]}
        {ast, state}

      other, state ->
        {other, state}
    end)
    |> Sourceror.to_string()
  end

  @doc """
  Injects new deps into the body of `aliases/0` private function of source.
  """
  def inject_aliases(source, new_source) when is_binary(new_source) do
    source
    |> Sourceror.parse_string!()
    |> Sourceror.postwalk(fn
      {:defp, meta, [{:aliases, _, _} = fun, body]}, state ->
        [{{_, _, [:do]}, do_block_ast}] = body
        {:__block__, block_meta, [aliases]} = do_block_ast

        new_aliases_line =
          case List.last(aliases) do
            {_, meta, _} ->
              meta[:line] || block_meta[:line]

            _ ->
              block_meta[:line]
          end + 1

        {:__block__, _block_meta, [new_aliases]} =
          new_source
          |> Sourceror.parse_string!()
          |> add_extra_leading_comment_eol()
          |> SourcerorExt.correct_lines(new_aliases_line)

        aliases = aliases ++ new_aliases

        ast = {:defp, meta, [fun, [do: {:__block__, block_meta, [aliases]}]]}
        {ast, state}

      other, state ->
        {other, state}
    end)
    |> Sourceror.to_string()
  end

  @doc """
  Injects new config into existing config.
  """
  def inject_config(source, new_source) when is_binary(new_source) do
    {:__block__, block_meta, config} =
      source
      |> Sourceror.parse_string!()
      |> SourcerorExt.to_block()

    new_config_line =
      config
      |> List.last()
      |> elem(1)
      |> Keyword.fetch!(:line)
      |> Kernel.+(1)

    {:__block__, _block_meta, new_config} =
      new_source
      |> Sourceror.parse_string!()
      |> add_extra_leading_comment_eol()
      |> SourcerorExt.correct_lines(new_config_line)
      |> SourcerorExt.to_block()

    {:__block__, block_meta, append_config(config, new_config)}
    |> Sourceror.to_string()
  end

  defp append_config(config, new_config) do
    {left, right} =
      Enum.split_while(config, fn one ->
        !match?({:import_config, _, _}, one)
      end)

    left ++ new_config ++ right
  end

  def add_extra_leading_comment_eol(ast) do
    extra_leading_comment_eol = 1

    {ast, is_added?} =
      Sourceror.postwalk(ast, false, fn
        {form, meta, args}, state ->
          if !state.acc do
            case Keyword.get(meta, :leading_comments) do
              [comment | rest] ->
                comments = [
                  Map.update!(comment, :previous_eol_count, &(&1 + extra_leading_comment_eol))
                  | rest
                ]

                meta = Keyword.put(meta, :leading_comments, comments)
                {{form, meta, args}, Map.put(state, :acc, true)}

              _ ->
                {{form, meta, args}, state}
            end
          else
            {{form, meta, args}, state}
          end

        ast, state ->
          {ast, state}
      end)

    if is_added?,
      do: SourcerorExt.correct_lines(ast, extra_leading_comment_eol),
      else: ast
  end
end
