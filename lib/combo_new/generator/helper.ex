defmodule ComboNew.Generator.Helper do
  @moduledoc false

  import Bitwise
  alias ComboNew.Git

  @mode Mix.env()

  @doc """
  Gets the list of template names.

  And they are sorted according to the complexity of their respective templates.
  """
  def get_template_names(root) do
    names =
      root
      |> File.ls!()
      |> Enum.filter(fn file ->
        file
        |> then(&Path.join(root, &1))
        |> File.dir?()
      end)

    orders = %{
      "vanilla" => 1,
      "vite" => 2
    }

    Enum.sort_by(names, fn name -> Map.get(orders, name, name) end)
  end

  @doc """
  Lists files of all templates.
  """
  def ls_all_template_files(root, template_names) do
    template_names
    |> Enum.map(fn template_name ->
      template_base_dir = Path.join(root, template_name)
      ls_template_files(template_base_dir)
    end)
    |> List.flatten()
  end

  @doc """
  Lists files.
  """
  def ls_template_files(dir) do
    if @mode == :prod,
      do: do_ls_files(dir),
      else: Git.ls_files(dir)
  end

  defp do_ls_files(dir) do
    "#{dir}/**/*"
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
  end

  def fetch_file_mode!(path) do
    mask = 0o777
    stat = File.stat!(path)
    stat.mode &&& mask
  end
end
