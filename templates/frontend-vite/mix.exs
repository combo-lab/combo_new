defmodule MyApp.MixProject do
  use Mix.Project

  @app :my_app
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
      listeners: [Combo.CodeReloader],
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp releases do
    [
      {@app, [include_executables_for: [:unix]]}
    ]
  end

  defp deps do
    [
      {:combo, path: "../../../combo", override: true},
      {:combo_vite, path: "../../../combo_vite", override: true},
      {:bandit, "~> 1.5"},
      {:system_env, "~> 0.1"},
      {:ex_check, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup"],
      "assets.setup": ["cmd --cd assets npm install --install-links"],
      "assets.build": ["cmd --cd assets npm run build"],
      "assets.clean": ["cmd rm -rf priv/static/build"],
      "assets.deploy": ["assets.clean", "assets.build"]
    ]
  end
end
