defmodule Mix.Tasks.Local.ComboNew do
  use Mix.Task

  @shortdoc "Updates combo_new locally"

  @moduledoc """
  Updates combo_new locally.

      $ mix local.combo_new

  It accepts the same command line options as `archive.install hex combo_new`.
  """

  @impl true
  def run(argv) do
    Mix.Task.run("archive.install", ["hex", "combo_new" | argv])
  end
end
