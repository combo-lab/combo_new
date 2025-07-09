defmodule ComboNew.Generator.Saas do
  @moduledoc false

  use ComboNew.Generator,
    template_path: Path.expand("../../../templates/saas", __DIR__),
    template_app: :combo_lt,
    template_module: ComboLT,
    template_env_prefix: "COMBO_LT"
end
