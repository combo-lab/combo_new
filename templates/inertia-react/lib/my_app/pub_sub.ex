defmodule MyApp.PubSub do
  @moduledoc """
  The Pub/Sub server.
  """

  @spec child_spec(keyword) :: Supervisor.child_spec()
  def child_spec(_) do
    Combo.PubSub.child_spec(name: __MODULE__)
  end
end
