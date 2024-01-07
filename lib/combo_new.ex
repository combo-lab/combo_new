defmodule ComboNew do
  @moduledoc """
  An opinionated project generator for Phoenix.
  """

  @doc """
  Generates a project with specified generator.
  """
  def run(generator, base_path, opts) do
    base_path = Path.expand(base_path)
    app = String.to_atom(opts[:app] || Path.basename(base_path))
    module = Module.concat([opts[:module] || camelize(app)])
    env_prefix = upcase(app)

    :ok = generator.generate(base_path, app: app, module: module, env_prefix: env_prefix)

    print_next_steps(base_path)
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
