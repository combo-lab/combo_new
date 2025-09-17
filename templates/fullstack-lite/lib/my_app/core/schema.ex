defmodule MyApp.Core.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @type t :: %__MODULE__{}

      @primary_key {:id, UUIDv7, autogenerate: true}
      @foreign_key_type UUIDv7

      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
