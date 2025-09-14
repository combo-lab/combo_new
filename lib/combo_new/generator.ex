defmodule ComboNew.Generator do
  @moduledoc false

  import __MODULE__.Helper,
    only: [
      get_template_names: 1,
      ls_all_template_files: 2,
      ls_template_files: 1,
      fetch_file_mode!: 1
    ]

  @template_app :demo_lt
  @template_module DemoLT
  @template_env_prefix "DEMO_LT"

  templates_root = Path.expand("../../templates", __DIR__)
  @templates_root templates_root

  template_names = get_template_names(templates_root)
  @template_names template_names

  ## control when this module is recompiled - begin --

  template_files = ls_all_template_files(templates_root, template_names)
  @template_files_hash :erlang.md5(template_files)

  for path <- template_files do
    @external_resource path
  end

  def __mix_recompile__?() do
    template_names = get_template_names(@templates_root)
    template_files = ls_all_template_files(@templates_root, template_names)
    :erlang.md5(template_files) != @template_files_hash
  end

  ## -- control when this module is recompiled - end

  @templates Enum.into(template_names, %{}, fn template_name ->
               template_base_dir = Path.join(templates_root, template_name)

               template_files =
                 template_base_dir
                 |> ls_template_files()
                 |> Enum.map(fn path ->
                   relative_path = Path.relative_to(path, template_base_dir)
                   content = File.read!(path)
                   mode = fetch_file_mode!(path)
                   {relative_path, mode, content}
                 end)

               {template_name, template_files}
             end)

  defp templates, do: @templates

  @doc """
  Lists all available template names.
  """
  def available_template_names do
    @template_names
  end

  @doc """
  Generates template files to `target_path`.
  """
  def generate!(
        target_path,
        template_name,
        [app: _, module: _, env_prefix: _] = replacements
      ) do
    placeholders = [
      app: @template_app,
      module: @template_module,
      env_prefix: @template_env_prefix
    ]

    files = Map.fetch!(templates(), template_name)
    create_files!(target_path, files, placeholders, replacements)
  end

  defp create_files!(target_path, template_files, placeholders, replacements) do
    for {path, mode, content} <- template_files do
      path = Path.join(target_path, path)
      create_file!(path, mode, content, placeholders, replacements)
    end

    :ok
  end

  defp create_file!(path, mode, content, placeholders, replacements) do
    placeholder_app = Keyword.fetch!(placeholders, :app)
    placeholder_module = Keyword.fetch!(placeholders, :module)
    placeholder_env_prefix = Keyword.fetch!(placeholders, :env_prefix)

    app = Keyword.fetch!(replacements, :app)
    module = Keyword.fetch!(replacements, :module)
    env_prefix = Keyword.fetch!(replacements, :env_prefix)

    content =
      content
      |> String.replace(to_string(placeholder_app), to_string(app))
      |> String.replace(inspect(placeholder_module), inspect(module))
      |> String.replace(placeholder_env_prefix, env_prefix)
      |> inject_secret_key_base()
      |> inject_signing_salt()

    path = path |> String.replace(to_string(placeholder_app), to_string(app))

    Mix.Generator.create_file(path, content)
    File.chmod!(path, mode)
    :ok
  end

  defp inject_secret_key_base(content) do
    placeholder = "=========================secret_key_base========================="
    replacement = random_string(64)
    new_content = String.replace(content, placeholder, replacement, global: false)

    if new_content == content do
      new_content
    else
      inject_secret_key_base(new_content)
    end
  end

  defp inject_signing_salt(content) do
    placeholder = "==signing_salt=="
    replacement = random_string(8)
    new_content = String.replace(content, placeholder, replacement, global: false)

    if new_content == content do
      new_content
    else
      inject_signing_salt(new_content)
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end
end
