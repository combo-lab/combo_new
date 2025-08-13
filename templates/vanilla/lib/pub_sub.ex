defmodule DemoLT.PubSub do
  @spec child_spec(keyword) :: Supervisor.child_spec()
  def child_spec(_) do
    Phoenix.PubSub.child_spec(name: __MODULE__)
  end
end
