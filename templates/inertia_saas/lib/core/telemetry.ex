defmodule InertiaSaaS.Core.Telemetry do
  @moduledoc false

  use CozyTelemetry.Spec

  @impl CozyTelemetry.Spec
  def metrics(_meta) do
    [
      summary("inertia_saas.core.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("inertia_saas.core.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("inertia_saas.core.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("inertia_saas.core.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("inertia_saas.core.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      )
    ]
  end
end
