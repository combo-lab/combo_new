defmodule ComboLT.MixProject do
  use Mix.Project

  @app :combo_lt
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps(),
      compilers: Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {ComboLT.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp releases do
    [
      {@app,
       [
         include_executables_for: [:unix]
       ]}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_reload, "~> 1.5", only: [:dev]},
      {:bandit, "~> 1.5"},
      {:cozy_env, "~> 0.2"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:jason, "~> 1.4"},

      # code quality
      {:ex_check, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["phx.digest"]
    ]
  end
end
