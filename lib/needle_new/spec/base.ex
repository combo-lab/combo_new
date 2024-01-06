defmodule NeedleNew.Spec.Base do
  @moduledoc false

  @unset :unset

  @fields [
    type: @unset,

    # root app
    root_app: @unset,
    root_module: @unset,
    root_app_path: @unset,

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
    |> put_binding()
  end

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

  defp put_binding(spec) do
    %{
      type: type,
      root_app: root_app,
      root_module: root_module
    } = spec

    binding = [
      type: type,
      root_app: root_app,
      root_module: root_module
    ]

    %{spec | binding: binding}
  end
end

defimpl NeedleNew.Specified, for: NeedleNew.Spec.Base do
  def get_binding(spec) do
    spec.binding
  end

  def get_path!(spec, path_name)
      when path_name in [:root_app] do
    Map.fetch!(spec, :"#{path_name}_path")
  end
end
