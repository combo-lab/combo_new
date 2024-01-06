defmodule NeedleNew.Generator do
  @moduledoc false

  import Mix.Generator
  alias NeedleNew.Specified
  alias NeedleNew.Codemod

  defmacro __using__(_env) do
    quote do
      import Mix.Generator
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro template(name, declarations) do
    declarations =
      Enum.map(declarations, fn
        {:{} = op, meta, [target_path_name, format, source]} ->
          {op, meta, [target_path_name, format, source, []]}

        {:{} = _op, _meta, [_target_path_name, _format, _source, _opts]} = ast ->
          ast

        ast ->
          raise CompileError,
            description: "invalid template declaration - #{Macro.to_string(ast)}"
      end)

    quote do
      @templates {unquote(name), unquote(declarations)}
    end
  end

  defmacro __before_compile__(env) do
    root = Path.expand("../../templates", __DIR__)

    templates_ast =
      for {name, declarations} <- Module.get_attribute(env.module, :templates) do
        for {_target_path_name, {type, action} = _format, source, _opts} <- declarations do
          source = to_string(source)

          source_path =
            root
            |> Path.join(source)
            |> sanitize_angle_brackets_path()

          if type in [:eex] do
            compiled = EEx.compile_file(source_path)

            quote do
              @external_resource unquote(source_path)
              @file unquote(source_path)
              def render(unquote(name), unquote(source), var!(assigns))
                  when is_list(var!(assigns)),
                  do: unquote(compiled)
            end
          else
            quote do
              @external_resource unquote(source_path)
              def render(unquote(name), unquote(source), _assigns),
                do: unquote(File.read!(source_path))
            end
          end
        end
      end

    quote do
      unquote(templates_ast)
      def templates(), do: @templates
      def fetch_template_declarations!(name), do: Keyword.fetch!(@templates, name)
    end
  end

  def copy_from(spec, module, name) when is_atom(name) do
    declarations = module.fetch_template_declarations!(name)
    binding = Specified.get_binding(spec)

    for {target_path_name, format, source, opts} <- declarations do
      root = Specified.get_path!(spec, target_path_name)

      target_relative_path =
        to_string(source)
        |> expand_path_with_binding(binding)
        |> remove_toplevel_dir()
        |> then(fn path ->
          if filename = opts[:filename],
            do: rename_file(path, filename),
            else: path
        end)

      target_path = Path.join(root, target_relative_path)

      case format do
        {:eex, :create_file} ->
          content = module.render(name, source, binding)
          create_file(target_path, content)

        {:eex, :merge_file} ->
          content = module.render(name, source, binding)
          merge_file(target_path, content)

        {:eex, :merge_mix} ->
          content = module.render(name, source, binding)
          merge_mix(target_path, content)

        {:eex, :merge_config} ->
          content = module.render(name, source, binding)
          merge_config(target_path, content)

        :dir ->
          File.mkdir_p!(target_path)

        :txt ->
          contents = module.render(name, source, binding)
          create_file(target_path, contents)

          # :config ->
          #   contents = module.render(name, source, binding)
          #   inject_config(target_path, contents)

          # :config_prod ->
          #   contents = module.render(name, source, binding)
          #   inject_config_prod_only(target_path, contents)
      end
    end
  end

  defp merge_file(path, new_content) do
    content = File.read!(path)
    content = Filemod.merge_file(content, new_content)
    File.write!(path, content)
  end

  defp merge_mix(path, new_content) do
    content = File.read!(path)
    content = Codemod.merge_mix(content, new_content)
    File.write!(path, content)
  end

  defp merge_config(path, new_content) do
    content =
      case File.read(path) do
        {:ok, binary} -> binary
        {:error, _} -> "import Config\n"
      end

    content = Codemod.merge_config(content, new_content)
    File.write!(path, content)
  end

  defp inject_config_prod_only(path, to_inject) do
    contents =
      case File.read(path) do
        {:ok, binary} ->
          binary

        {:error, _} ->
          """
          import Config

          if config_env() == :prod do
          end
          """
      end

    case :binary.split(contents, "if config_env() == :prod do") do
      [left, right] ->
        write_formatted!(path, [left, "if config_env() == :prod do\n", to_inject, right])

      [_] ->
        file = Path.basename(path)
        Mix.raise(~s[Could not find "if config_env() == :prod do" in #{inspect(file)}])
    end
  end

  defp write_formatted!(path, contents) do
    formatted = contents |> IO.iodata_to_binary() |> Code.format_string!()
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, [formatted, ?\n])
  end

  # converts needle_ctx/lib/<*ctx_lib>.ex like path to needle_ctx/lib/.ex
  # converts needle_ctx/lib/<ctx_lib>.ex like path to needle_ctx/lib/ctx_lib.ex
  defp sanitize_angle_brackets_path(path) do
    path =
      Regex.replace(Regex.recompile!(~r/<(\*[a-zA-Z0-9_]+)>/), path, fn _full, _key -> "" end)

    path = path |> Path.split() |> Path.join()
    Regex.replace(Regex.recompile!(~r/<([a-zA-Z0-9_]+)>/), path, fn _full, key -> key end)
  end

  # expands needle_ctx/lib/<*ctx_lib>.ex like path to needle_ctx/lib/demo.ex
  # expands needle_ctx/lib/<ctx_lib>.ex like path to needle_ctx/lib/demo.ex
  defp expand_path_with_binding(path, binding) do
    Regex.replace(Regex.recompile!(~r/<\*?([a-zA-Z0-9_]+)>/), path, fn _full, key ->
      binding |> Keyword.fetch!(:"#{key}") |> to_string()
    end)
  end

  # converts needle_ctx/lib/<ctx_lib>.ex like path to lib/<ctx_lib>.ex
  defp remove_toplevel_dir(path) do
    {toplevel_dir, rest} =
      path
      |> Path.split()
      |> List.pop_at(0)

    if rest == [] do
      raise RuntimeError, "one level path is not supported"
    end

    Path.relative_to(path, toplevel_dir)
  end

  defp rename_file(path, filename) do
    path
    |> Path.dirname()
    |> Path.join(filename)
    |> Path.relative_to(".")
  end
end
