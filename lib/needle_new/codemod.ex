defmodule NeedleNew.Codemod do
  alias __MODULE__.SourcerorExt

  @doc """
  Extracts var from pattern when the pattern is found in given AST.

  ## Examples

      # extract args from pattern {:defmodule, _meta, args}
      extract_pattern_var(ast, {:defmodule, _meta, args}, args)

  """
  defmacro extract_pattern_var(ast, pattern, var) do
    quote do
      try do
        Sourceror.prewalk(unquote(ast), fn
          unquote(pattern), state ->
            throw(unquote(var))

          other, state ->
            {other, state}
        end)
      catch
        # found
        :throw, value ->
          value
      else
        # not found
        _ ->
          nil
      end
    end
  end

  @doc """
  Returns module name of AST.
  """
  def get_module_name!(ast) do
    case extract_pattern_var(ast, {:defmodule, _, [{:__aliases__, _, aliases} | _]}, aliases) do
      nil ->
        raise RuntimeError, "failed to get module name"

      aliases ->
        Module.concat(aliases)
    end
  end

  @doc """
  Merges content of two mix.exs files.
  """
  def merge_mix(source, new_source) do
    source_ast = Sourceror.parse_string!(source)
    new_source_ast = Sourceror.parse_string!(new_source)

    new_source_deps =
      extract_pattern_var(
        new_source_ast,
        {:defp, meta, [{:deps, _, _}, [{{_, _, [:do]}, {:__block__, _, [deps]}}]]},
        deps
      )

    new_source_aliases =
      extract_pattern_var(
        new_source_ast,
        {:defp, meta, [{:aliases, _, _}, [{{_, _, [:do]}, {:__block__, _, [aliases]}}]]},
        aliases
      )

    source_ast =
      if new_source_deps,
        do: inject_deps(source_ast, new_source_deps),
        else: source_ast

    source_ast =
      if new_source_aliases,
        do: inject_aliases(source_ast, new_source_aliases),
        else: source_ast

    source_ast
    |> Sourceror.to_string()
    |> String.trim()
    |> Kernel.<>("\n")
  end

  defp inject_deps(ast, new_deps) do
    Sourceror.postwalk(ast, fn
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

        new_deps =
          new_deps
          |> add_extra_leading_comment_eol()
          |> SourcerorExt.correct_lines(new_deps_line)

        deps = deps ++ new_deps

        ast = {:defp, meta, [fun, [do: {:__block__, block_meta, [deps]}]]}
        {ast, state}

      other, state ->
        {other, state}
    end)
  end

  defp inject_aliases(ast, new_aliases) do
    Sourceror.postwalk(ast, fn
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

        new_aliases =
          new_aliases
          |> add_extra_leading_comment_eol()
          |> SourcerorExt.correct_lines(new_aliases_line)

        aliases = aliases ++ new_aliases

        ast = {:defp, meta, [fun, [do: {:__block__, block_meta, [aliases]}]]}
        {ast, state}

      other, state ->
        {other, state}
    end)
  end

  @doc """
  Merges content of two config files.
  """
  def merge_config(source, new_source) when is_binary(new_source) do
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

  defp add_extra_leading_comment_eol(ast) do
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
