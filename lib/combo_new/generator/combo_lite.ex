defmodule ComboNew.Generator.ComboLite do
  @moduledoc false

  use ComboNew.Generator,
    template_path: Path.expand("../../../templates/combo_lite", __DIR__),
    template_app: :combo_lite,
    template_module: ComboLite,
    template_env_prefix: "COMBO_LITE"
end
