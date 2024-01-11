defmodule Mix.Tasks.ComboNew.Lite do
  use Mix.Task

  @shortdoc "Creates a Phoenix project in Lite type"

  @moduledoc """
  #{@shortdoc}.

  This type assumes that the project is for building a simple website, which
  generally only includes web interface for users.

  In order to facilitate a smooth transition to a SaaS type when business
  changes in the future, this type adopts a project structure consistent with
  the SaaS type.

  ## Usage

  It expects the path of the project as an argument.

      $ mix combo_new.lite PATH [--app APP] [--module MODULE]

  A project at the given PATH will be created. The application name and module
  name will be retrieved from the `PATH`, unless `--app` or `--module` is given.

  ## Options

    * `--app` - the name of the OTP application.

    * `--module` - the name of the base module in the generated skeleton.

    * `-v`, `--version` - prints the version.

  """

  @impl true
  def run(argv) do
    ComboNew.run(__MODULE__, ComboNew.Generator.ComboLite, argv)
  end
end
