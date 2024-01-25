defmodule ComboNew.Generator do
  @moduledoc false

  import Bitwise
  alias ComboNew.Git

  @mode Mix.env()

  defmacro __using__(opts) do
    template_path = Keyword.fetch!(opts, :template_path)
    template_app = Keyword.fetch!(opts, :template_app)
    template_module = Keyword.fetch!(opts, :template_module)
    template_env_prefix = Keyword.fetch!(opts, :template_env_prefix)

    quote do
      @template_path unquote(template_path)
      @template_app unquote(template_app)
      @template_module unquote(template_module)
      @template_env_prefix unquote(template_env_prefix)

      paths = Git.ls_files(@template_path)

      @paths_hash :erlang.md5(paths)

      for path <- paths do
        @external_resource path
      end

      def __mix_recompile__?() do
        Git.ls_files(@template_path) |> :erlang.md5() != @paths_hash
      end

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    template_path = Module.get_attribute(env.module, :template_path)

    fetch_file_mode = fn path ->
      mask = 0o777
      stat = File.stat!(path)
      stat.mode &&& mask
    end

    template_files =
      template_path
      |> fetch_template_files()
      |> Enum.map(fn path ->
        relative_path = Path.relative_to(path, template_path)
        content = File.read!(path)
        mode = fetch_file_mode.(path)
        Macro.escape({relative_path, mode, content})
      end)

    quote do
      @template_files unquote(template_files)

      def template_files(), do: @template_files

      def generate(target_path, [app: app, module: module, env_prefix: env_prefix] = replacements) do
        slots = [app: @template_app, module: @template_module, env_prefix: @template_env_prefix]
        unquote(__MODULE__).create_files(target_path, @template_files, slots, replacements)
        :ok
      end
    end
  end

  defp fetch_template_files(dir) do
    if @mode == :prod,
      do: fetch_all_files(dir),
      else: Git.ls_files(dir)
  end

  defp fetch_all_files(dir) do
    "#{dir}/**/*"
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
  end

  def create_files(target_path, template_files, slots, replacements) do
    for {path, mode, content} <- template_files do
      path = Path.join(target_path, path)
      create_file(path, mode, content, slots, replacements)
    end
  end

  defp create_file(path, mode, content, slots, replacements) do
    slot_app = Keyword.fetch!(slots, :app)
    slot_module = Keyword.fetch!(slots, :module)
    slot_env_prefix = Keyword.fetch!(slots, :env_prefix)

    app = Keyword.fetch!(replacements, :app)
    module = Keyword.fetch!(replacements, :module)
    env_prefix = Keyword.fetch!(replacements, :env_prefix)

    content =
      content
      |> String.replace(to_string(slot_app), to_string(app))
      |> String.replace(inspect(slot_module), inspect(module))
      |> String.replace(slot_env_prefix, env_prefix)
      |> inject_secret_key_base()
      |> inject_signing_salt()

    Mix.Generator.create_file(path, content)
    File.chmod!(path, mode)
  end

  defp inject_secret_key_base(content) do
    pattern = "=========================secret_key_base========================="
    replacement = random_string(64)
    new_content = String.replace(content, pattern, replacement, global: false)

    if new_content == content do
      new_content
    else
      inject_secret_key_base(new_content)
    end
  end

  defp inject_signing_salt(content) do
    pattern = "==signing_salt=="
    replacement = random_string(8)
    new_content = String.replace(content, pattern, replacement, global: false)

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
