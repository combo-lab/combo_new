defmodule ComboNew.MixProject do
  use Mix.Project

  @version "0.12.0"
  @description "The project generator for Combo."
  @elixir_requirement "~> 1.18"
  @source_url "https://github.com/combo-lab/combo_new"

  def project do
    [
      app: :combo_new,
      version: @version,
      elixir: @elixir_requirement,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      dialyzer: dialyzer(),
      package: package(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_check, ">= 0.0.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CREATING_TEMPLATES.md", "LICENSE"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix]
    ]
  end

  defp package do
    [
      files: ~w(lib templates mix.exs README.md),
      links: %{"Source" => @source_url},
      licenses: ["MIT"]
    ]
  end

  defp aliases do
    [
      publish: ["clean_templates", "hex.publish", "tag"],
      clean_templates: &clean_templates/1,
      tag: &tag_release/1
    ]
  end

  defp clean_templates(_) do
    System.cmd("git", ["clean", "-d", "-f", "-x", "templates"])
  end

  defp tag_release(_) do
    Mix.shell().info("Tagging release as v#{@version}")
    System.cmd("git", ["tag", "v#{@version}", "--message", "Release v#{@version}"])
    System.cmd("git", ["push", "--tags"])
  end
end
