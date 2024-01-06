defmodule NeedleNew.Spec.Web do
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
    module: @unset,
    app_path: @unset,
    var_prefix: @unset,
    env_prefix: @unset,
    lib_name: @unset,
    lib_rpath: @unset,
    priv_rpath: @unset,
    assets_rpath: :unset,

    # derived binding
    binding: []
  ]

  @enforce_keys Keyword.keys(@fields)
  defstruct @fields

  @phoenix_version "1.7.10"

  def new!(config) when is_list(config) do
    config
    |> as_map!()
    |> as_struct!()
    |> validate!()
    |> put_opts()
    |> put_binding()
  end

  def dashboard?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :dashboard)
  def assets?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :assets)
  def html?(%__MODULE__{} = spec), do: Keyword.fetch!(spec.opts, :html)
  def live?(%__MODULE__{} = spec), do: html?(spec) && Keyword.fetch!(spec.opts, :live)
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
      http_server: Keyword.get(opts, :http_server, "cowboy"),
      dashboard: Keyword.get(opts, :dashboard, true),
      assets: Keyword.get(opts, :assets, true),
      html: Keyword.get(opts, :html, true),
      live: Keyword.get(opts, :live, true),
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
      module: module,
      var_prefix: var_prefix,
      env_prefix: env_prefix,
      lib_name: lib_name,
      lib_rpath: lib_rpath,
      priv_rpath: priv_rpath,
      assets_rpath: assets_rpath
    } = spec

    http_server = Keyword.fetch!(opts, :http_server)

    {
      phoenix_adapter_app,
      phoenix_adapter_vsn,
      phoenix_adapter_module,
      phoenix_adapter_config
    } = get_phoenix_adapter(http_server)

    binding = [
      type: type,
      root_app: root_app,
      root_module: root_module,
      app: app,
      module: module,
      var_prefix: var_prefix,
      env_prefix: env_prefix,
      lib_name: lib_name,
      lib_rpath: lib_rpath,
      priv_rpath: priv_rpath,
      assets_rpath: assets_rpath,
      # TODO: assets_reverse_rpath
      dashboard?: dashboard?(spec),
      assets?: assets?(spec),
      html?: html?(spec),
      live?: live?(spec),
      i18n?: i18n?(spec),
      phoenix_version: @phoenix_version,
      phoenix_dep: ~s[{:phoenix, "~> #{@phoenix_version}"}],
      phoenix_adapter_app: phoenix_adapter_app,
      phoenix_adapter_vsn: phoenix_adapter_vsn,
      phoenix_adapter_module: phoenix_adapter_module,
      phoenix_adapter_config: phoenix_adapter_config,
      phoenix_secret_key_base_dev: random_string(64),
      phoenix_secret_key_base_test: random_string(64),
      phoenix_signing_salt: random_string(8),
      phoenix_live_view_signing_salt: random_string(8)
    ]

    %{spec | binding: binding}
  end

  defp get_phoenix_adapter("cowboy"),
    do:
      {:plug_cowboy, "~> 2.5", Phoenix.Endpoint.Cowboy2Adapter,
       [
         dev_http_options: """
         transport_options: [num_acceptors: 2]
         """
       ]}

  defp get_phoenix_adapter("bandit"),
    do:
      {:bandit, ">= 0.0.0", Bandit.PhoenixAdapter,
       [
         dev_http_options: """
         thousand_island_options: [num_acceptors: 2]
         """
       ]}

  defp get_phoenix_adapter(other),
    do: Mix.raise("Unknown http server #{inspect(other)}")

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end
end

defimpl NeedleNew.Specified, for: NeedleNew.Spec.Web do
  def get_binding(%NeedleNew.Spec.Web{} = spec) do
    spec.binding
  end

  def get_path!(%NeedleNew.Spec.Web{} = spec, path_name)
      when path_name in [:root_app, :app] do
    Map.fetch!(spec, :"#{path_name}_path")
  end
end
