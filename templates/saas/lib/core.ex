defmodule DemoLT.Core do
  @moduledoc """
  `DemoLT.Core` keeps the contexts that define the domain
  and business logic.

  Contexts are also responsible for managing data, regardless
  if it comes from the database, an external API or others.
  """

  use Boundary,
    deps: [
      Ecto,
      Ecto.Changeset,
      DemoLT.Toolkit,
      DemoLT.I18n
    ],
    exports: [
      Supervisor
    ]
end
