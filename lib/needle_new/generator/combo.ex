defmodule NeedleNew.Generator.Combo do
  @moduledoc false

  use NeedleNew.Generator

  template(:base, [
    {:root_app, {:eex, :create_file}, "combo_base/README.md"},
    {:root_app, {:eex, :create_file}, "combo_base/gitignore", filename: ".gitignore"},
    {:root_app, {:eex, :create_file}, "combo_base/mix.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/formatter.exs", filename: ".formatter.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/config/config.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/config/dev.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/config/prod.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/config/test.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/config/runtime.exs"},
    {:root_app, {:eex, :create_file}, "combo_base/lib/<root_app>_application.ex"},
    {:root_app, {:eex, :create_file}, "combo_base/test/test_helper.exs"}
  ])

  template(:core, [
    {:root_app, {:eex, :merge_file}, "combo_core/gitignore", filename: ".gitignore"},
    {:root_app, {:eex, :merge_mix}, "combo_core/mix.exs"},
    {:root_app, {:eex, :merge_config}, "combo_core/config/config.exs"},
    {:root_app, {:eex, :merge_config}, "combo_core/config/dev.exs"},
    {:root_app, {:eex, :merge_config}, "combo_core/config/prod.exs"},
    {:root_app, {:eex, :merge_config}, "combo_core/config/test.exs"},
    {:root_app, {:eex, :merge_config}, "combo_core/config/runtime.exs"},
    {:app, {:eex, :create_file}, "combo_core/lib/<name>.ex"},
    {:app, {:eex, :create_file}, "combo_core/lib/<name>/supervisor.ex"},
    {:app, {:eex, :create_file}, "combo_core/lib/<name>/telemetry.ex"},
    # ecto
    {:app, {:eex, :create_file}, "combo_core/lib/<name>/repo.ex"},
    {:app, {:eex, :create_file}, "combo_core/priv/<name>/repo/migrations/formatter.exs",
     filename: ".formatter.exs"},
    {:app, {:eex, :create_file}, "combo_core/priv/<name>/repo/seeds.exs"},
    {:app, {:eex, :merge_file}, "combo_core/test/test_helper.exs"},
    # mailer
    {:app, {:eex, :create_file}, "combo_core/lib/<name>/mailer.ex"}
  ])

  # template(:web, [
  #   {:root_app, {:eex, :merge_file}, "combo_web/gitignore", filename: ".gitignore"},
  #   {:app, {:eex, :merge_config}, "combo_web/config/config.exs"},
  #   {:app, {:eex, :merge_config}, "combo_web/config/dev.exs"},
  #   {:app, {:eex, :merge_config}, "combo_web/config/test.exs"}
  # ])

  def copy() do
    spec =
      NeedleNew.Spec.Base.new!(
        type: :normal,
        root_app: :demo,
        root_module: Demo,
        root_app_path: "/tmp/demo"
      )

    copy_from(spec, __MODULE__, :base)

    spec =
      NeedleNew.Spec.Core.new!(
        type: :normal,
        opts: [],
        root_app: :demo,
        root_module: Demo,
        root_app_path: "/tmp/demo",
        app: :demo,
        name: "demo",
        module: Demo,
        app_path: "/tmp/demo",
        var_prefix: "demo_",
        env_prefix: "DEMO_",
        lib_name: "demo",
        lib_rpath: "lib/demo",
        priv_rpath: "priv/demo"
      )

    copy_from(spec, __MODULE__, :core)
  end
end
