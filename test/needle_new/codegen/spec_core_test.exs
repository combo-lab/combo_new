defmodule NeedleNew.Codegen.SpecCoreTest do
  use ExUnit.Case

  alias NeedleNew.Spec.Core, as: SpecCore

  test "new!/1" do
    SpecCore.new!(
      type: :normal,
      opts: [],
      root_app: :demo,
      root_module: Demo,
      root_app_path: "/tmp/demo",
      app: :core,
      module: Core,
      app_path: "/tmp/demo/apps/core",
      var_prefix: "core_",
      env_prefix: "CORE_",
      lib_name: "lib/core",
      lib_rpath: "lib/core",
      priv_rpath: "priv"
    )
    |> IO.inspect()
  end
end
