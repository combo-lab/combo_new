defmodule Mix.Tasks.ComboNew.Update do
  use Mix.Task

  @shortdoc "Updates combo_new locally"

  @moduledoc """
  Updates combo_new locally.

  ## Usage

  ```console
  $ mix combo_new.update
  ```

  It accepts the same command line options as `archive.install hex combo_new`.
  """

  @impl true
  def run(argv) do
    Mix.Task.run("archive.install", ["hex", "combo_new" | argv])
  end
end
