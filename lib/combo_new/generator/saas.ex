defmodule ComboNew.Generator.Saas do
  @moduledoc false

  use ComboNew.Generator,
    template_path: Path.expand("../../../templates/saas", __DIR__),
    template_app: :demo_lt,
    template_module: DemoLT,
    template_env_prefix: "DEMO_LT"
end
