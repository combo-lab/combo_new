defmodule Mix.Tasks.ComboNew do
  use Mix.Task
  alias ComboNew.Generator

  @shortdoc "Generates a Combo project"

  @moduledoc ~s'''
  #{@shortdoc}.

  ## Examples

  Generates a project from the `vanilla` template in the `./demo` directory:
  ```console
  $ mix combo_new vanilla demo
  ```

  Generates a project from the `vanilla` template in the `/tmp/demo` directory:
  ```console
  $ mix combo_new vanilla /tmp/demo
  ```

  Generates a project from the `vanilla` template in the `./demo` directory, but
  specifying the name of the OTP application as `rina`:

  ```console
  $ mix combo_new vanilla demo --app rina
  ```

  ## Usage

  ```console
  $ mix combo_new <template> <path> [--app APP] [--module MODULE]
  ```

  ### Arguments

    * `<template>` - the name of template. Available templates:
  #{Generator.available_template_names() |> Enum.map(&"#{String.duplicate(" ", 6)}- `#{&1}`") |> Enum.join("\n")}

    * `<path>` - the path of the generated project. It can be an absolute or
      a relative path. The OTP application name and base module name will be
      retrieved from the path, unless `--app` or `--module` option is given.

  ### Options

    * `--app` - the name of the OTP application. If it's not specified, the name
      will be retrieved from the `<path>`.

    * `--module` - the name of the base module. If it's not specified, the name
      will be retrieved from the name of the OTP application.

    * `-v`, `--version` - prints the version.
  '''

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  @elixir_requirement Mix.Project.config()[:elixir]

  @support_options [
    app: :string,
    module: :string
  ]

  @impl true
  def run([option] = _argv) when option in ~w(-v --version) do
    Mix.shell().info("#{@app} v#{@version}")
  end

  def run(argv) do
    check_elixir_version!()

    case OptionParser.parse!(argv, strict: @support_options) do
      {opts, [template_name, target_path | _]} ->
        generate(target_path, template_name, opts)

      _ ->
        task_name = to_mix_task_name(__MODULE__)
        Mix.Tasks.Help.run([task_name])
    end
  end

  # ComboNew.run(__MODULE__, argv)

  defp check_elixir_version!() do
    unless Version.match?(System.version(), @elixir_requirement) do
      Mix.raise(
        "#{@app} v#{@version} requires Elixir #{@elixir_requirement}. " <>
          "But, you have Elixir #{System.version()}. \n" <> "Please update accordingly."
      )
    end
  end

  defp generate(target_path, template_name, opts) do
    target_path = Path.expand(target_path)

    app = String.to_atom(opts[:app] || Path.basename(target_path))
    module = Module.concat([opts[:module] || camelize(app)])
    env_prefix = upcase(app)

    check_target_path!(target_path)
    check_template_name!(template_name)
    check_app_name!(app, !!opts[:app])
    check_module_name!(module)

    :ok =
      Generator.generate!(target_path, template_name,
        app: app,
        module: module,
        env_prefix: env_prefix
      )

    print_next_steps(target_path)
  end

  defp check_target_path!(path) do
    cond do
      not File.exists?(path) ->
        :ok

      File.exists?(path) and not File.dir?(path) ->
        Mix.raise("The path #{path} already exists, but it's not a directory. Abort.")

      File.exists?(path) and File.dir?(path) ->
        continue? =
          Mix.shell().yes?("""
          The path #{path} already exists. Are you sure you want to continue?\
          """)

        if continue?,
          do: :ok,
          else: Mix.raise("Please use another path.")
    end
  end

  defp check_template_name!(name) do
    available_template_names = Generator.available_template_names()

    if name in available_template_names do
      :ok
    else
      Mix.raise("""
      Unknown template name - #{name}. Available template names are:

      #{available_template_names |> Enum.map(&"#{String.duplicate(" ", 2)}- #{&1}") |> Enum.join("\n")}
      """)
    end
  end

  defp check_app_name!(name, app_opt_passed?) do
    name = to_string(name)

    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      extra_msg =
        if !app_opt_passed? do
          ". The application name is inferred from the path, if you'd like to " <>
            "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore, got: #{inspect(name)}" <> extra_msg
      )
    end
  end

  defp check_module_name!(name) do
    unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir module name (for example: Foo.Bar), got: #{inspect(name)}"
      )
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

  defp print_next_steps(target_path) do
    Mix.shell().info("""

    We are almost there! The following steps are missing:

        $ cd #{relative_path(target_path)}
        $ mix setup

    Then, start the app with:

        $ mix combo.serve

    Or, run the app inside IEx (Interactive Elixir) as:

        $ iex -S mix combo.serve
    """)
  end

  defp relative_path(path) do
    case Path.relative_to_cwd(path) do
      ^path -> Path.basename(path)
      rel -> rel
    end
  end

  defp to_mix_task_name(mix_task_module) do
    "Mix.Tasks." <> module = inspect(mix_task_module)

    module
    |> String.split(".")
    |> Enum.map(&Macro.underscore/1)
    |> Enum.join(".")
  end
end
