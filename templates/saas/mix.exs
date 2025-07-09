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
      compilers: compilers(),
      listeners: [Phoenix.CodeReloader],
      boundary: boundary(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ComboLT.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies configuration for releases.
  #
  # Type `mix help release` for examples and options.
  defp releases do
    [
      {@app,
       [
         include_executables_for: [:unix]
       ]}
    ]
  end

  # Specifies the project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # distribution
      {:dns_cluster, "~> 0.2"},

      # config
      {:cozy_env, "~> 0.2"},

      # core
      {:argon2_elixir, "~> 4.0"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:uuidv7, "~> 1.0"},
      {:swoosh, "~> 1.16"},
      {:finch, "~> 0.17"},

      # i18n
      {:gettext, "~> 0.26"},

      # web
      {:cozy_proxy, "~> 0.4"},
      {:bandit, "~> 1.5"},
      {:plug_probe, "~> 0.1"},
      {:phoenix, "~> 1.8.0-rc.3", override: true},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_live_view, "~> 1.1.0-rc.0"},
      {:combo_vite,
       path: "../../../combo_vite"},
      {:phoenix_live_reload, "~> 1.5", only: [:dev]},
      {:floki, ">= 0.30.0", only: [:test]},

      # monitoring
      {:cozy_telemetry, "~> 0.5"},

      # utils
      {:jason, "~> 1.4"},

      # code quality
      {:boundary, "~> 0.10", runtime: false},
      {:ex_check, ">= 0.0.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev], runtime: false},

      # test
      {:ex_machina, "~> 2.8", only: [:test]}
    ]
  end

  defp compilers do
    extra_compilers(Mix.env()) ++ Mix.compilers()
  end

  defp extra_compilers(:test), do: []
  defp extra_compilers(_env), do: [:boundary]

  defp boundary do
    [
      default: [
        check: [
          # enable checking alias references
          aliases: true,
          apps: [
            :phoenix,
            :ecto,
            # warn the runtime calls of Mix, which is not available in release
            {:mix, :runtime}
          ]
        ]
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup"],
      "test.setup": [
        "cmd MIX_ENV=test mix ecto.reset"
      ],

      # ! high-level aliases

      # for testing release locally
      "release.local": ["assets.setup", "assets.build", "release"],

      # ! group aliases

      "ecto.setup": ["core.ecto.setup"],
      "ecto.reset": ["core.ecto.reset"],
      "assets.setup": ["user_web.assets.setup", "admin_web.assets.setup"],
      "assets.build": ["user_web.assets.build", "admin_web.assets.build"],

      # ! i18n

      "i18n.gettext.merge": ["gettext.extract", "gettext.merge priv/i18n/gettext"],
      "i18n.gettext.add_locale": ["gettext.merge priv/i18n/gettext --locale"],

      # ! core

      "core.ecto.setup": [
        "ecto.create -r ComboLT.Core.Repo",
        "ecto.migrate -r ComboLT.Core.Repo",
        "run priv/core/repo/seeds.exs"
      ],
      "core.ecto.drop": "ecto.drop -r ComboLT.Core.Repo",
      "core.ecto.reset": ["core.ecto.drop", "core.ecto.setup"],

      # ! user_web

      "user_web.assets.setup": ["cmd --cd assets/user_web npm install"],
      "user_web.assets.build": ["cmd --cd assets/user_web npm run build"],

      # ! admin_web

      "admin_web.assets.setup": ["cmd --cd assets/admin_web npm install"],
      "admin_web.assets.build": ["cmd --cd assets/admin_web npm run build"]
    ]
  end
end
