defmodule LiveSaaS.Core.Accounts.UserToken do
  @moduledoc false

  use LiveSaaS.Core.Schema
  alias LiveSaaS.Core.Accounts.User

  @type_defs [
    email_change: %{
      format: {:digit, size: 6},
      ttl_in_minutes: 30
    },
    password_change: %{
      format: {:digit, size: 6},
      ttl_in_minutes: 30
    },
    password_reset: %{
      format: {:digit, size: 6},
      # Since someone has access to the token may take over the account, it is
      # important to keep the ttl of password_reset token short, which helps
      # to minimize the window of vulnerability.
      ttl_in_minutes: 15
    }
  ]

  @types Keyword.keys(@type_defs)

  schema "accounts_user_tokens" do
    belongs_to :user, User
    field :sent_to, :string
    field :type, Ecto.Enum, values: @types
    field :token_hash, :binary
    field :payload, :map

    timestamps(updated_at: false)
  end

  # Generates @type type :: :email_change | ... from the `@types` module attribute.
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
