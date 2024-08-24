defmodule ComboSaaS.Core.Accounts.NoUserToken do
  @moduledoc false

  use ComboSaaS.Core.Schema

  @type_defs [
    register: %{
      format: {:digit, size: 6},
      ttl_in_minutes: 30
    }
  ]

  @types Keyword.keys(@type_defs)

  schema "accounts_no_user_tokens" do
    field :sent_to, :string
    field :type, Ecto.Enum, values: @types
    field :token_hash, :binary
    field :payload, :map

    timestamps(updated_at: false)
  end

  # Generates @type type :: :register | ... from the `@types` module attribute.
  @type type ::
          unquote(
            Enum.reduce(
              Enum.reverse(@types),
              &quote(do: unquote(&1) | unquote(&2))
            )
          )

  @spec type_defs :: [{type(), map()}]
  def type_defs, do: @type_defs

  for {type,
       %{
         format: format,
         ttl_in_minutes: ttl_in_minutes
       }} <- @type_defs do
    @spec format(unquote(type)) :: unquote(format)
    def format(unquote(type)), do: unquote(format)

    @spec ttl_in_minutes(unquote(type)) :: unquote(ttl_in_minutes)
    def ttl_in_minutes(unquote(type)), do: unquote(ttl_in_minutes)
  end
end
