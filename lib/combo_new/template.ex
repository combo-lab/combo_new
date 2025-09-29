defmodule ComboNew.Template do
  @moduledoc false

  import Bitwise
  alias ComboNew.Git

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
      "vite" => 2,
      "inertia-react" => 2,
      "fullstack-lite" => 3
    }

    Enum.sort_by(names, fn name -> Map.get(orders, name, name) end)
  end

  def ls_template_files(root, template_names) when is_list(template_names) do
    template_names
    |> Enum.map(fn template_name ->
      dir = Path.join(root, template_name)
      ls_files(dir)
    end)
    |> List.flatten()
  end

  def scan_template_tuples(root) do
    absolute_paths = ls_files(root)

    Enum.map(absolute_paths, fn path ->
      relative_path = Path.relative_to(path, root)
      mode = fetch_file_mode!(path)
      content = File.read!(path)
      {relative_path, mode, content}
    end)
  end

  defp ls_files(dir) do
    if Git.in_repo?(dir) do
      Git.ls_files(dir)
    else
      dir
      |> Path.join("**/*")
      |> Path.wildcard(match_dot: true)
      |> Enum.filter(&File.regular?/1)
    end
  end

  defp fetch_file_mode!(path) do
    mask = 0o777
    stat = File.stat!(path)
    stat.mode &&& mask
  end
end
