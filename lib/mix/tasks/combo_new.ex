defmodule Mix.Tasks.ComboNew do
  use Mix.Task
  alias ComboNew.Generator
  alias ComboNew.Error

  @shortdoc "Generates a Combo project"

  @moduledoc ~s'''
  #{@shortdoc}.

  ## Usage

  ```console
  $ mix combo_new <template> <path> [--app APP] [--module MODULE]
  ```

  ### Arguments

    * `<template>` - the name of a built-in template, or the address of a Git
      repo, which is useful to use your own templates.
      * Supported built-in templates: #{Generator.builtin_template_names() |> Enum.map_join(", ", &"`#{&1}`")}.
      * Supported protocols of the address of Git repos: `https://`, `ssh://`, `file://`.

    * `<path>` - the path of the generated project. It can be an absolute or
      a relative path. The OTP application name and base module name will be
      retrieved from the path, unless `--app` or `--module` option is given.

  ### Options

    * `--app` - the name of the OTP application. If it's not specified, the name
      will be retrieved from the `<path>`.

    * `--module` - the name of the base module. If it's not specified, the name
      will be retrieved from the name of the OTP application.

    * `-v`, `--version` - prints the version.

  ## Examples

  Generates a project from the `frontend-vanilla` template in the `./demo`
  directory:

  ```console
  $ mix combo_new frontend-vanilla demo
  ```

  Generates a project in the `./demo` directory, using a remote Git repository
  as the template:

  ```console
  $ mix combo_new https://github.com/namespace/name.git demo
  ```

  Generates a project from the `frontend-vanilla` template in the `/tmp/demo`
  directory:

  ```console
  $ mix combo_new frontend-vanilla /tmp/demo
  ```

  Generates a project from the `frontend-vanilla` template in the `./demo`
  directory, but specifying the name of the OTP application as `rina`:

  ```console
  $ mix combo_new frontend-vanilla demo --app rina
  ```
  '''

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  @elixir_requirement Mix.Project.config()[:elixir]

  @version_line "#{@app} v#{@version}"

  @support_options [
    app: :string,
    module: :string
  ]

  @impl true
  def run([option] = _argv) when option in ~w(-v --version) do
    Mix.shell().info(@version_line)
  end

  def run(argv) do
    check_elixir_version!()

    case OptionParser.parse!(argv, strict: @support_options) do
      {opts, [template, target_path | _]} ->
        generate(template, target_path, opts)

      _ ->
        task_name = to_mix_task_name(__MODULE__)
        Mix.Tasks.Help.run([task_name])
    end
  end

  defp check_elixir_version! do
    if not Version.match?(System.version(), @elixir_requirement) do
      exit_with_msg(:dep_error, """
      #{@version_line} requires Elixir #{@elixir_requirement}. \
      But, you have Elixir #{System.version()}.
      Please update accordingly.\
      """)
    end
  end

  defp generate(template, target_path, opts) do
    target_path = Path.expand(target_path)

    app_name = opts[:app] || Path.basename(target_path)
    module_name = opts[:module] || camelize(app_name)

    template = check_template!(template)
    check_target_path!(target_path)
    check_app_name!(app_name, !!opts[:app])
    check_module_name!(module_name)

    app = String.to_atom(app_name)
    module = Module.concat([module_name])

    try do
      Generator.generate!(template, target_path, app, module)
    rescue
      e in [Error] ->
        msg = Exception.message(e)
        exit_with_msg(:runtime_error, msg)
    end

    print_next_steps(target_path)
  end

  defp check_template!(template) do
    case Generator.cast_template(template) do
      {:ok, template} -> template
      {:error, msg} -> exit_with_msg(:arg_error, msg)
    end
  end

  defp check_target_path!(path) do
    cond do
      not File.exists?(path) ->
        :ok

      File.exists?(path) and not File.dir?(path) ->
        exit_with_msg(:arg_error, """
        The path #{path} already exists, and it's not a directory. \
        It's impossible to generate files into it, exit.\
        """)

      File.exists?(path) and File.dir?(path) ->
        continue? =
          Mix.shell().yes?("""
          The path #{path} already exists. Are you sure you want to continue?\
          """)

        if continue?,
          do: :ok,
          else: exit_with_msg(:ok, "Please use another path.")
    end
  end

  defp check_app_name!(name, app_opt_passed?) do
    name = to_string(name)

    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      extra_msg =
        if app_opt_passed? do
          ""
        else
          ". If you'd like to explicitly name it, then use the `--app` option."
        end

      exit_with_msg(:arg_error, """
      #{inspect(name)} is not a valid OTP application name. \
      The OTP application name must start with a lowercase letter and contain \
      only lowercase letters, numbers, and underscores#{extra_msg}\
      """)
    end
  end

  defp check_module_name!(name) when is_binary(name) do
    if not (name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/)) do
      exit_with_msg(:arg_error, """
      #{inspect(name)} is not a valid module name. \
      The module name must be a valid Elixir module name, such as "MyApp".
      """)
    end
  end

  defp camelize(term) when is_binary(term) do
    Macro.camelize(term)
  end

  defp print_next_steps(target_path) do
    Mix.shell().info("""

    Done! Now run:

        $ cd #{relative_path(target_path)}
        $ mix setup
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
    |> Enum.map_join(".", &Macro.underscore/1)
  end

  @spec exit_with_msg(atom(), String.t()) :: no_return()
  defp exit_with_msg(type, msg) do
    output_device = if type == :ok, do: :stdio, else: :stderr
    IO.puts(output_device, msg)

    exit_code =
      case type do
        :ok -> 0
        :runtime_error -> 1
        :arg_error -> 2
        :dep_error -> 7
      end

    System.halt(exit_code)
  end
end
