defmodule InertiaSaaS.Core do
  @moduledoc """
  `InertiaSaaS.Core` keeps the contexts that define the domain
  and business logic.

  Contexts are also responsible for managing data, regardless
  if it comes from the database, an external API or others.
  """

  use Boundary,
    deps: [
      Ecto,
      Ecto.Changeset,
      InertiaSaaS.Toolkit,
      InertiaSaaS.I18n
    ],
    exports: [
      Supervisor
    ]
end
