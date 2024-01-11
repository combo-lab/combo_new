# Use Mix.Tasks.ComboNew.Saas instead of Mix.Tasks.ComboNew.SaaS
#
# Because the Mix task names are derived from the module name, in order to
# make `mix combo_new.saas` work, I have to use this strange module name.
defmodule Mix.Tasks.ComboNew.Saas do
  use Mix.Task

  @shortdoc "Creates a Phoenix project in SaaS type"

  @moduledoc """
  #{@shortdoc}.

  This type assumes that the project is for building SaaS, which generally
  includes following parts:

    1. core logic for the business
    2. web interface for users
    3. web interface for administrators
    4. web API for users (for developer-oriented SaaS)

  ## Usage

  It expects the path of the project as an argument.

      $ mix combo_new.saas PATH [--app APP] [--module MODULE]

  A project at the given PATH will be created. The application name and module
  name will be retrieved from the `PATH`, unless `--app` or `--module` is given.

  ## Options

    * `--app` - the name of the OTP application.

    * `--module` - the name of the base module in the generated skeleton.

    * `-v`, `--version` - prints the version.

  """

  @impl true
  def run(argv) do
    ComboNew.run(__MODULE__, ComboNew.Generator.ComboSaaS, argv)
  end
end
