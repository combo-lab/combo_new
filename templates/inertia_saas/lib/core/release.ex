defmodule InertiaSaaS.Core.Release do
  @moduledoc """
  Release-related DB tasks for production environment without Mix installed.

  ## Functions

  This module provides multiple public functions.

  ### For migrating database structure

    * `migrate/0` / `migrate/1`
    * `rollback/0` / `rollback/1`

  ### For populating data into database

    * `seed/0`
    * `seed/1`

  ### For migrating the data in database

    * `migrate_data/0`
    * `migrate_data/1`

  ## Run a function manually

  Run the functions in this module by calling `eval` command provided by release.
  For example:

  ```sh
  $RELEASE_ROOT/bin/$RELEASE_NAME eval '#{inspect(__MODULE__)}.migrate()'
  ```

  ## Run a function automatically

  For example, when starting a release:


  ```
  # mix release.init && $EDITOR rel/env.sh.eex
  case $RELEASE_COMMAND in
      start*)
          "$RELEASE_ROOT/bin/$RELEASE_NAME" eval '#{inspect(__MODULE__)}.migrate()'
          ;;
      *)
          ;;
  esac
  ```

  Read more details and examples at:

    * https://hexdocs.pm/ecto_sql/3.7.2/Ecto.Migrator.html#module-example-running-migrations-in-a-release
    * https://hexdocs.pm/phoenix/1.6.6/releases.html#ecto-migrations-and-custom-commands

  """

  @type opts :: keyword()
  @type result :: {:ok, term()} | {:error, term()}
  @type script_result :: {:ok, term()} | no_return()

  @app :inertia_saas
  @repo InertiaSaaS.Core.Repo

  @doc """
  Migrates the database.

  It accepts the same `opts` of `Ecto.Migrator.run/4`.
  """
  @spec migrate(opts()) :: result()
  def migrate(opts \\ [all: true]) do
    load_apps()

    path = path_for_migrations(@repo)
    up_for(@repo, path, opts)
  end

  @doc """
  Rollbacks the database.

  It accepts the same `opts` of `Ecto.Migrator.run/4`.
  """
  @spec rollback(opts()) :: result()
  def rollback(opts \\ [step: 1]) do
    load_apps()

    path = path_for_migrations(@repo)
    down_for(@repo, path, opts)
  end

  @doc """
  Runs seeds.

  When using `all: true` option, it expect a file which are located in
  `priv/<namespace>/seeds.exs`. And, `priv/<namespace>/seeds.exs` is
  free to call any seeds in `priv/<namespace>/seeds/`. You can use this
  function as a batch operation for seeding
  `priv/<namespace>/seeds/<name>.exs`.

  When using `:name` option, it expects a file which are located in
  `priv/<namespace>/seeds/<name>.exs`.

  ## Example `priv/<namespace>/seeds.exs`

      [
        "foo.exs",
        "bar.exs",
        # ...
      ]
      |> Enum.each(fn file ->
        Code.eval_file(file, Path.join(__DIR__, "./seeds"))
      end)

  """
  @spec seed :: no_return()
  def seed, do: raise("I don't know what to do")

  @spec seed(opts()) :: script_result()
  def seed(opts) do
    load_apps()

    case opts do
      [all: true] ->
        seed_all()

      [name: name] ->
        seed_one(name)

      _ ->
        raise "unknown options - #{inspect(opts)}"
    end
  end

  defp seed_all do
    script = priv_path_for(@repo, "seeds.exs")
    run_script(@repo, script)
  end

  defp seed_one(name) do
    script = priv_path_for(@repo, "seeds/#{name}.exs")
    run_script(@repo, script)
  end

  @doc """
  Runs data migrations.

  When using `all: true` option, it expect a file which are located in
  `priv/<namespace>/data_migrations.exs`. And,
  `priv/<namespace>/data_migrations.exs` is free to call any data
  migraions in `priv/<namespace>/data_migrations/`. You can use this
  function as a batch operation for seeding
  `priv/<namespace>/data_migrations/<name>.exs`.

  When using `:name` option, it expects a file which are located in
  `priv/<namespace>/data_migrations/<name>.exs`.

  ## Example `priv/<namespace>/data_migrations.exs`

      [
        "foo.exs",
        "bar.exs",
        # ...
      ]
      |> Enum.each(fn file ->
        Code.eval_file(file, Path.join(__DIR__, "./data_migrations"))
      end)

  """
  @spec migrate_data :: no_return()
  def migrate_data, do: raise("I don't know what to do")

  @spec migrate_data(opts()) :: script_result()
  def migrate_data(opts) do
    load_apps()

    case opts do
      [all: true] ->
        migrate_all_data()

      [name: name] ->
        migrate_one_data(name)

      _ ->
        raise "unknown options - #{inspect(opts)}"
    end
  end

  defp migrate_all_data do
    script = priv_path_for(@repo, "data_migrations.exs")
    run_script(@repo, script)
  end

  defp migrate_one_data(name) do
    script = priv_path_for(@repo, "data_migrations/#{name}.exs")
    run_script(@repo, script)
  end

  defp load_apps do
    Application.ensure_loaded(@app)
  end

  defp path_for_migrations(repo) do
    Ecto.Migrator.migrations_path(repo)
  end

  defp up_for(repo, path, opts) do
    Ecto.Migrator.with_repo(repo, fn repo ->
      Ecto.Migrator.run(repo, path, :up, opts)
    end)
    |> case do
      {:ok, fun_return, _} -> {:ok, fun_return}
      {:error, reason} -> {:error, reason}
    end
  end

  defp down_for(repo, path, opts) do
    Ecto.Migrator.with_repo(repo, fn repo ->
      Ecto.Migrator.run(repo, path, :down, opts)
    end)
    |> case do
      {:ok, fun_return, _} -> {:ok, fun_return}
      {:error, reason} -> {:error, reason}
    end
  end

  defp run_script(repo, path) do
    Ecto.Migrator.with_repo(repo, fn _repo ->
      if File.exists?(path) do
        {result, _binding} = Code.eval_file(path)
        {:return, result}
      else
        {:abort, :bad_path, path}
      end
    end)
    |> case do
      {:ok, {:return, result}, _} ->
        {:ok, result}

      {:ok, {:abort, :bad_path, path}, _} ->
        raise RuntimeError, "script doesn't exist - #{path}"

      {:error, term} ->
        raise RuntimeError, "error occurs when running Ecto.Migrator.with_repo - #{inspect(term)}"
    end
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)
    priv_dir = "#{:code.priv_dir(app)}"

    [_app_underscore, namespace_underscore, repo_underscore] =
      repo
      |> Module.split()
      |> Enum.map(&Macro.underscore/1)

    Path.join([priv_dir, namespace_underscore, repo_underscore, filename])
  end
end
