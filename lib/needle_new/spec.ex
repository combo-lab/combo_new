defmodule NeedleNew.Codegen.Spec do
  @moduledoc false

  @fields [
    :type,
    :base_path,
    :opts,
    :app,
    :module
  ]

  @enforce_keys @fields
  defstruct @fields

  def new!(type, base_path, opts) do
    base_path = Path.expand(base_path)
    app = String.to_atom(opts[:app] || Path.basename(base_path))
    module = Module.concat([opts[:module] || camelize(app)])

    %__MODULE__{
      type: type,
      base_path: base_path,
      opts: opts,
      app: app,
      module: module
    }
  end

  defp camelize(term) when is_atom(term) do
    term
    |> Atom.to_string()
    |> Macro.camelize()
  end

  # Puts binding into %Project{} struct.
  # def put_binding(%__MODULE__{} = project) do
  #   web_assets_reverse_rpath =
  #     case type.name do
  #       :single -> ""
  #       :umbrella -> "../.."
  #       :combo -> ".."
  #     end
  # end

  # # Validates the given %Project{} struct.
  # defp validate!(%__MODULE__{} = project) do
  #   check_app_validity!(project.app, !!project.opts[:app])
  #   # check_directory_existence!(project.root_app_path)
  #   check_module_validity!(project.module)
  #   check_module_availability!(project.module)

  #   project
  # end

  # defp check_app_validity!(app, from_app_option) do
  #   app_name = to_string(app)

  #   unless app_name =~ Regex.recompile!(~r/^[a-z][\w_]*$/) do
  #     extra =
  #       if from_app_option do
  #         ""
  #       else
  #         ". The application name is inferred from the path, if you'd like to " <>
  #           "explicitly name the application then use the `--app APP` option."
  #       end

  #     Mix.raise(
  #       "Application name must start with a letter and have only lowercase " <>
  #         "letters, numbers and underscore, got: #{inspect(app_name)}" <> extra
  #     )
  #   end
  # end

  # defp check_directory_existence!(path) do
  #   if File.dir?(path) do
  #     Mix.raise(
  #       "The directory #{path} already exists. Please select another directory for installation."
  #     )
  #   end
  # end

  # defp check_module_validity!(name) do
  #   unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
  #     Mix.raise(
  #       "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
  #     )
  #   end
  # end

  # defp check_module_availability!(name) do
  #   [name]
  #   |> Module.concat()
  #   |> Module.split()
  #   |> Enum.reduce([], fn name, acc ->
  #     mod = Module.concat([Elixir, name | acc])

  #     if Code.ensure_loaded?(mod) do
  #       Mix.raise("Module name #{inspect(mod)} is already taken, please choose another name")
  #     else
  #       [name | acc]
  #     end
  #   end)
  # end

  # def get_path!(%__MODULE__{} = project, path_name)
  #     when path_name in [:root_app, :ctx_app, :web_app] do
  #   Map.fetch!(project, :"#{path_name}_path")
  # end

  # def phoenix_version(), do: @phoenix_version
end
