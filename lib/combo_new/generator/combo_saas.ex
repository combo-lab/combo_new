defmodule ComboNew.Generator.ComboSaaS do
  @moduledoc false

  use ComboNew.Generator,
    template_path: Path.expand("../../../templates/combo_saas", __DIR__),
    template_app: :combo_saas,
    template_module: ComboSaaS,
    template_env_prefix: "COMBO_SAAS"
end
