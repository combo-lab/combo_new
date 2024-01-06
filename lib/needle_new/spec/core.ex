defmodule NeedleNew.Spec.Core do
  @moduledoc false

  @unset :unset

  @fields [
    type: @unset,
    opts: @unset,

    # root app
    root_app: @unset,
    root_module: @unset,
    root_app_path: @unset,

    # app
    app: @unset,
    name: @unset,
    module: @unset,
    app_path: @unset,
    var_prefix: @unset,
    env_prefix: @unset,
    lib_name: @unset,
    lib_rpath: @unset,
    priv_rpath: @unset,

    # derived binding
    binding: []
  ]

  @enforce_keys Keyword.keys(@fields)
  defstruct @fields

  def new!(config) when is_list(config) do
    config
    |> as_map!()
    |> as_struct!()
    |> validate!()
    |> put_opts()
    |> put_binding()
  end

  def ecto?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :ecto)
  def mailer?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :mailer)
  def i18n?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :i18n)

  defp as_map!(config) when is_list(config), do: Enum.into(config, %{})

  defp as_map!(config) do
    raise ArgumentError,
          "config must be a keyword list, but #{inspect(config)} is given"
  end

  defp as_struct!(config) do
    default_struct = __MODULE__.__struct__()
    valid_keys = Map.keys(default_struct)
    config = Map.take(config, valid_keys)
    Map.merge(default_struct, config)
  end

  defp validate!(struct) do
    keys = Map.keys(struct)
    unset_keys = Enum.filter(keys, fn key -> Map.get(struct, key) == @unset end)

    if unset_keys != [] do
      raise RuntimeError, "following keys #{inspect(unset_keys)} should be set"
    end

    struct
  end

  defp put_opts(spec) do
    %{opts: opts} = spec

    opts = [
      database: Keyword.get(opts, :database, "postgres"),
      binary_id: Keyword.get(opts, :binary_id, false),
      ecto: Keyword.get(opts, :ecto, true),
      mailer: Keyword.get(opts, :mailer, true),
      i18n: Keyword.get(opts, :i18n, true)
    ]

    %{spec | opts: opts}
  end

  defp put_binding(spec) do
    %{
      type: type,
      opts: opts,
      root_app: root_app,
      root_module: root_module,
      app: app,
      name: name,
      module: module,
      var_prefix: var_prefix,
      env_prefix: env_prefix,
      lib_name: lib_name,
      lib_rpath: lib_rpath,
      priv_rpath: priv_rpath
    } = spec

    database = Keyword.fetch!(opts, :database)
    binary_id = Keyword.fetch!(opts, :binary_id)

    # We lowercase the database name because according to the
    # SQL spec, they are case insensitive unless quoted, which
    # means creating a database like FoO is the same as foo in
    # some storages.
    {
      ecto_adapter_app,
      ecto_adapter_module,
      ecto_adapter_config
    } = get_ecto_adapter(spec, database, String.downcase(Atom.to_string(app)), module)

    ecto_adapter_config = Keyword.put_new(ecto_adapter_config, :binary_id, binary_id)

    binding = [
      type: type,
      root_app: root_app,
      root_module: root_module,
      app: app,
      name: name,
      module: module,
      var_prefix: var_prefix,
      env_prefix: env_prefix,
      lib_name: lib_name,
      lib_rpath: lib_rpath,
      priv_rpath: priv_rpath,
      ecto?: ecto?(spec),
      mailer?: mailer?(spec),
      i18n?: i18n?(spec),
      ecto_adapter_app: ecto_adapter_app,
      ecto_adapter_module: ecto_adapter_module,
      ecto_adapter_config: ecto_adapter_config
    ]

    %{spec | binding: binding}
  end

  defp get_ecto_adapter(spec, "mssql", app, module) do
    {
      :tds,
      Ecto.Adapters.Tds,
      socket_db_config(spec, app, module, "sa", "some!Password")
    }
  end

  defp get_ecto_adapter(spec, "mysql", app, module) do
    {
      :myxql,
      Ecto.Adapters.MyXQL,
      socket_db_config(spec, app, module, "root", "")
    }
  end

  defp get_ecto_adapter(spec, "postgres", app, module) do
    {
      :postgrex,
      Ecto.Adapters.Postgres,
      socket_db_config(spec, app, module, "postgres", "postgres")
    }
  end

  defp get_ecto_adapter(spec, "sqlite3", app, module) do
    {
      :ecto_sqlite3,
      Ecto.Adapters.SQLite3,
      fs_db_config(spec, app, module)
    }
  end

  defp get_ecto_adapter(_spec, db, _app, _mod) do
    Mix.raise("Unknown database #{inspect(db)}")
  end

  defp socket_db_config(spec, app, module, user, pass) do
    %{var_prefix: var_prefix, env_prefix: env_prefix} = spec

    [
      dev: """
      username: #{inspect(user)},
      password: #{inspect(pass)},
      hostname: "localhost",
      database: "#{app}_dev",
      stacktrace: true,
      show_sensitive_data_on_connection_error: true,
      pool_size: 10
      """,
      test: """
      username: #{inspect(user)},
      password: #{inspect(pass)},
      hostname: "localhost",
      database: #{~s|"#{app}_test\#{System.get_env("#{env_prefix}MIX_TEST_PARTITION")}"|},
      pool: Ecto.Adapters.SQL.Sandbox,
      pool_size: 10
      """,
      test_setup_all: "Ecto.Adapters.SQL.Sandbox.mode(#{inspect(module)}.Repo, :manual)",
      test_setup: """
          pid = Ecto.Adapters.SQL.Sandbox.start_owner!(#{inspect(module)}.Repo, shared: not tags[:async])
          on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)\
      """,
      prod_vars: """
      #{var_prefix}database_url =
        System.get_env("#{env_prefix}DATABASE_URL") ||
          raise \"""
          environment variable #{env_prefix}DATABASE_URL is missing.
          You should set it to something like: "ecto://USER:PASS@HOST/DATABASE"
          \"""

      #{var_prefix}database_pool_size = String.to_integer(System.get_env("#{env_prefix}DATABASE_POOL_SIZE") || "10")
      maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

      """,
      prod: """
      # ssl: true,
      url: #{var_prefix}database_url,
      pool_size: #{var_prefix}database_pool_size,
      socket_options: maybe_ipv6
      """
    ]
  end

  defp fs_db_config(spec, app, module) do
    %{var_prefix: var_prefix, env_prefix: env_prefix} = spec

    [
      dev: """
      database: #{~s|Path.expand("../#{app}_dev.db", Path.dirname(__ENV__.file))|},
      pool_size: 5,
      stacktrace: true,
      show_sensitive_data_on_connection_error: true
      """,
      test: """
      database: #{~s|Path.expand("../#{app}_test.db", Path.dirname(__ENV__.file))|},
      pool_size: 5,
      pool: Ecto.Adapters.SQL.Sandbox
      """,
      test_setup_all: "Ecto.Adapters.SQL.Sandbox.mode(#{inspect(module)}.Repo, :manual)",
      test_setup: """
          pid = Ecto.Adapters.SQL.Sandbox.start_owner!(#{inspect(module)}.Repo, shared: not tags[:async])
          on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)\
      """,
      prod_vars: """
      #{var_prefix}database_path =
        System.get_env("#{env_prefix}DATABASE_PATH") ||
          raise \"""
          environment variable #{env_prefix}DATABASE_PATH is missing.
          You should set it to something like: "/etc/#{app}/#{app}.db"
          \"""
      """,
      prod: """
      database: #{var_prefix}database_path,
      pool_size: String.to_integer(System.get_env("#{env_prefix}DATABASE_POOL_SIZE") || "5")
      """
    ]
  end
end

defimpl NeedleNew.Specified, for: NeedleNew.Spec.Core do
  def get_binding(%NeedleNew.Spec.Core{} = spec) do
    spec.binding
  end

  def get_path!(%NeedleNew.Spec.Core{} = spec, path_name)
      when path_name in [:root_app, :app] do
    Map.fetch!(spec, :"#{path_name}_path")
  end
end
