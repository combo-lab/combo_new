defmodule ComboNew.Generator do
  @moduledoc false

  alias ComboNew.Template
  alias ComboNew.Git

  @template_app :my_app
  @template_module MyApp
  @template_env_prefix "MY_APP"

  templates_root = Path.expand("../../templates", __DIR__)
  @templates_root templates_root

  template_names = Template.get_template_names(templates_root)
  @template_names template_names

  ## control when this module is recompiled - begin --

  template_files = Template.ls_template_files(templates_root, template_names)
  @template_files_hash :erlang.md5(template_files)

  for path <- template_files do
    @external_resource path
  end

  def __mix_recompile__?() do
    template_names = Template.get_template_names(@templates_root)
    template_files = Template.ls_template_files(@templates_root, template_names)
    :erlang.md5(template_files) != @template_files_hash
  end

  ## -- control when this module is recompiled - end

  @templates Enum.into(template_names, %{}, fn template_name ->
               template_root = Path.join(templates_root, template_name)
               template_tuples = Template.scan_template_tuples(template_root)
               {template_name, template_tuples}
             end)

  defp templates, do: @templates

  @doc """
  Lists the built-in template names.
  """
  def builtin_template_names, do: @template_names

  @doc """
  Validates and transform template.
  """
  def cast_template(template) do
    cond do
      possible_template_name?(template) ->
        name = template
        template_names = builtin_template_names()

        if name in template_names do
          {:ok, {:builtin_template, name}}
        else
          msg = """
          #{inspect(name)} is not a valid template. \
          Expected the name of a built-in template, or the address of a Git repo.\
          """

          {:error, msg}
        end

      Git.addr?(template) ->
        addr = template
        {:ok, {:git_repo, addr}}

      true ->
        msg = """
        #{inspect(template)} is not a valid template. \
        Expected the name of a built-in template, or the address of a Git repo.\
        """

        {:error, msg}
    end
  end

  @doc """
  Generates template files to `target_path`.
  """
  def generate!(template, target_path, app, module) when is_atom(app) and is_atom(module) do
    placeholders = %{
      app: @template_app,
      module: @template_module,
      env_prefix: @template_env_prefix
    }

    replacements = %{
      app: app,
      module: module,
      env_prefix: upcase(app)
    }

    create_files!(template, target_path, placeholders, replacements)
  end

  defp possible_template_name?(template), do: Regex.match?(~r/^[a-zA-Z0-9_-]+$/, template)

  defp create_files!({:builtin_template, name}, root, placeholders, replacements) do
    template_tuples = Map.fetch!(templates(), name)

    for template_tuple <- template_tuples do
      create_file!(template_tuple, root, placeholders, replacements)
    end

    :ok
  end

  defp create_files!({:git_repo, addr}, root, placeholders, replacements) do
    cond do
      Git.remote_addr?(addr) ->
        Git.with_cloned_repo(addr, fn dest ->
          template_tuples = Template.scan_template_tuples(dest)

          for template_tuple <- template_tuples do
            create_file!(template_tuple, root, placeholders, replacements)
          end

          :ok
        end)

      Git.local_addr?(addr) ->
        path = Git.trim_addr_protocol(addr)
        path = Path.expand(path)
        template_tuples = Template.scan_template_tuples(path)

        for template_tuple <- template_tuples do
          create_file!(template_tuple, root, placeholders, replacements)
        end

        :ok
    end
  end

  defp create_file!(
         {relative_path, mode, content} = _template_tuple,
         root,
         placeholders,
         replacements
       ) do
    %{
      app: placeholder_app,
      module: placeholder_module,
      env_prefix: placeholder_env_prefix
    } = placeholders

    %{
      app: app,
      module: module,
      env_prefix: env_prefix
    } = replacements

    path =
      relative_path
      |> String.replace(to_string(placeholder_app), to_string(app))
      |> then(&Path.join(root, &1))

    content =
      content
      |> String.replace(to_string(placeholder_app), to_string(app))
      |> String.replace(inspect(placeholder_module), inspect(module))
      |> String.replace(placeholder_env_prefix, env_prefix)
      |> inject_random_string()

    Mix.Generator.create_file(path, content)
    File.chmod!(path, mode)

    :ok
  end

  def inject_random_string(content) do
    random_string_pattern =
      Regex.recompile!(~r/"=+\s*random_string\(\s*(?<length>\d+)\s*\)\s*\=+"/)

    Regex.scan(random_string_pattern, content)
    |> Enum.map(fn [placeholder, raw_length] ->
      length = String.to_integer(raw_length)
      replacement = "\"#{random_string(length)}\""
      {placeholder, replacement}
    end)
    |> Enum.reduce(content, fn {placeholder, replacement}, acc ->
      String.replace(acc, placeholder, replacement, global: false)
    end)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end

  defp upcase(term) when is_atom(term) do
    term
    |> Atom.to_string()
    |> String.upcase()
  end
end
