defmodule DemoLT.MixProject do
  use Mix.Project

  @app :demo_lt
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps(),
      compilers: Mix.compilers(),
      listeners: [Combo.CodeReloader],
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {DemoLT.Application, []},
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
      {:combo, path: "../../../combo"},
      {:bandit, "~> 1.5"},
      {:cozy_env, "~> 0.2"},

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
