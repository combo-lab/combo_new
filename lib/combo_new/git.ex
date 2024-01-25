defmodule ComboNew.Git do
  @moduledoc false

  def ls_files(dir) do
    root_dir = root_dir()

    cli = "git ls-tree --full-name --name-only -r HEAD ."

    {cmd, args} =
      cli
      |> String.split(~r|\s+|)
      |> List.pop_at(0)

    files =
      case System.cmd(cmd, args, cd: dir) do
        {result, 0} ->
          result
          |> String.trim()
          |> String.split("\n")

        _ ->
          raise RuntimeError, "unable to list git files"
      end

    Enum.map(files, &Path.join(root_dir, &1))
  end

  defp root_dir do
    cli = "git rev-parse --show-toplevel"

    {cmd, args} =
      cli
      |> String.split(~r|\s+|)
      |> List.pop_at(0)

    {result, 0} = System.cmd(cmd, args)
    String.trim(result)
  end
end
