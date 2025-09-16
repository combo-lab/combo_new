defmodule ComboNew.Git do
  @moduledoc false

  alias ComboNew.Error

  @doc """
  Checks whether a given directory is in a repo.
  """
  def in_repo?(dir) do
    if System.find_executable("git"),
      do: check_repo_with_git(dir),
      else: check_repo_with_recursive_find(dir)
  end

  defp check_repo_with_git(dir) do
    case git("rev-parse --is-inside-work-tree", cd: dir, stderr_to_stdout: true) do
      {:ok, result} ->
        if String.trim(result) == "true", do: true, else: false

      :error ->
        false
    end
  end

  defp check_repo_with_recursive_find(dir) do
    dot_git_path = Path.join(dir, ".git")

    cond do
      File.dir?(dot_git_path) ->
        true

      Path.dirname(dir) == dir ->
        # reached the root of file system
        false

      true ->
        parent_dir = Path.dirname(dir)
        check_repo_with_recursive_find(parent_dir)
    end
  end

  @doc """
  Checks whether a given address is a valid address of repo.
  """
  def addr?(addr) do
    pattern = ~r<^(https|ssh|file)://[^\s]+$>
    Regex.match?(pattern, addr)
  end

  @doc """
  Checks whether a given address is a valid address of remote repo.
  """
  def remote_addr?(addr) do
    pattern = ~r<^(https|ssh)://[^\s]+$>
    Regex.match?(pattern, addr)
  end

  @doc """
  Checks whether a given address is a valid address of local repo.
  """
  def local_addr?(addr) do
    pattern = ~r<^(file)://[^\s]+$>
    Regex.match?(pattern, addr)
  end

  @doc """
  Trims the protocol part from addr.
  """
  def trim_addr_protocol(addr) do
    protocol = ~r<^[^:]+://>
    String.replace(addr, protocol, "")
  end

  @doc """
  Clones a repo, and run the given `fun` in the context of cloned repo.

  And, the cloned repo will be cleaned up.
  """
  def with_cloned_repo(addr, fun) when is_function(fun, 1) do
    tmp_dir = System.tmp_dir!() |> realpath()
    now = System.system_time()
    dest = Path.join(tmp_dir, "git-#{now}")

    try do
      git!("clone --depth 1 #{addr} #{dest}")
      fun.(dest)
    after
      File.rm_rf!(dest)
    end
  end

  def ls_files(dir) do
    root = root_dir(dir)
    result = git!("ls-files --full-name", cd: dir)

    result
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Path.join(root, &1))
  end

  defp root_dir(dir) do
    result = git!("rev-parse --show-toplevel", cd: dir)
    String.trim(result)
  end

  defp git(line, opts) when is_binary(line) do
    cmd = cmd!()
    args = build_args(line)

    case System.cmd(cmd, args, opts) do
      {result, 0} -> {:ok, result}
      {_, _} -> :error
    end
  end

  defp git!(line, opts \\ []) when is_binary(line) do
    {:ok, result} = git(line, opts)
    result
  end

  defp cmd! do
    if cmd = System.find_executable("git") do
      cmd
    else
      raise Error, "git is not found in PATH"
    end
  end

  defp build_args(line) when is_binary(line) do
    String.split(line, ~r|\s+|)
  end

  # On macOS, System.tmp_dir!/0 builds path like "/var/folders/9l/sg1005113pg_3vddkgyknfb80000gn/T/",
  # but it's realpath is "/private/var/folders/9l/sg1005113pg_3vddkgyknfb80000gn/T/".
  #
  # In other parts of code, I always use the realpath, so it's better to transform it.
  def realpath("/" <> _ = path) do
    path
    |> Path.split()
    |> Enum.reduce("/", fn subpath, acc ->
      current_path = Path.join(acc, subpath)

      case File.read_link(current_path) do
        {:ok, target} ->
          # credo:disable-for-next-line
          if Path.type(target) == :absolute do
            target
          else
            current_dir = Path.dirname(current_path)
            Path.expand(target, current_dir)
          end

        {:error, _} ->
          current_path
      end
    end)
  end

  def realpath(path), do: path
end
