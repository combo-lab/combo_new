defmodule ComboNew do
  @moduledoc """
  The project generator for Combo.
  """

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  @elixir_requirement Mix.Project.config()[:elixir]

  @support_options [
    app: :string,
    module: :string
  ]

  @doc """
  Runs a generator with Mix task.
  """
  def run(_mix_task_module, _generator, [option] = _agrv)
      when option in ~w(-v --version) do
    Mix.shell().info("#{@app} v#{@version}")
  end

  def run(mix_task_module, generator, argv) do
    elixir_version_check!()

    case OptionParser.parse!(argv, strict: @support_options) do
      {opts, [base_path | _]} ->
        generate(generator, base_path, opts)

      _ ->
        task_name = to_mix_task_name(mix_task_module)
        Mix.Tasks.Help.run([task_name])
    end
  end

  defp elixir_version_check!() do
    unless Version.match?(System.version(), @elixir_requirement) do
      Mix.raise(
        "#{@app} v#{@version} requires Elixir #{@elixir_requirement}. " <>
          "But, you have Elixir #{System.version()}. \n" <> "Please update accordingly."
      )
    end
  end

  defp to_mix_task_name(mix_task_module) do
    "Mix.Tasks." <> module = inspect(mix_task_module)

    module
    |> String.split(".")
    |> Enum.map(&Macro.underscore/1)
    |> Enum.join(".")
  end

  @doc """
  Generates a project.
  """
  def generate(generator, base_path, opts) do
    base_path = Path.expand(base_path)

    app = String.to_atom(opts[:app] || Path.basename(base_path))
    module = Module.concat([opts[:module] || camelize(app)])
    env_prefix = upcase(app)

    check_app_name!(app, !!opts[:app])
    check_module_name!(module)
    check_directory_existence!(base_path)

    :ok = generator.generate(base_path, app: app, module: module, env_prefix: env_prefix)

    print_next_steps(base_path)
  end

  defp check_app_name!(name, from_app_option) do
    name = to_string(name)

    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      extra =
        if !from_app_option do
          ". The application name is inferred from the path, if you'd like to " <>
            "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore, got: #{inspect(name)}" <> extra
      )
    end
  end

  defp check_module_name!(name) do
    unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_directory_existence!(path) do
    if File.dir?(path) and
         not Mix.shell().yes?(
           "The directory #{path} already exists. Are you sure you want to continue?"
         ) do
      Mix.raise("Please select another directory for installation.")
    end
  end

  defp camelize(term) when is_atom(term) do
    term
    |> Atom.to_string()
    |> Macro.camelize()
  end

  defp upcase(term) when is_atom(term) do
    term
    |> Atom.to_string()
    |> String.upcase()
  end

  defp print_next_steps(base_path) do
    Mix.shell().info("""

    We are almost there! The following steps are missing:

        $ cd #{relative_path(base_path)}
        $ mix setup

    Then, start the app with:

        $ mix phx.server

    Or, run the app inside IEx (Interactive Elixir) as:

        $ iex -S mix phx.server

    """)
  end

  defp relative_path(path) do
    case Path.relative_to_cwd(path) do
      ^path -> Path.basename(path)
      rel -> rel
    end
  end
end
