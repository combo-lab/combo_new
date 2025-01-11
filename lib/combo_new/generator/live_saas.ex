defmodule ComboNew.Generator.LiveSaaS do
  @moduledoc false

  use ComboNew.Generator,
    template_path: Path.expand("../../../templates/live_saas", __DIR__),
    template_app: :live_saas,
    template_module: LiveSaaS,
    template_env_prefix: "LIVE_SAAS"
end
