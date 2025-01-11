defmodule InertiaSaaS.PubSub do
  @moduledoc false

  use Boundary,
    deps: [],
    exports: []

  @spec child_spec(keyword) :: Supervisor.child_spec()
  def child_spec(_) do
    Phoenix.PubSub.child_spec(name: __MODULE__)
  end
end
