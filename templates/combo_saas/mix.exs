defmodule ComboSaaS.MixProject do
  use Mix.Project

  @app :combo_saas
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ComboSaaS.Application, []},
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
      {:dns_cluster, "~> 0.1.1"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:cozy_proxy, "~> 0.3"},
      {:cozy_env, "~> 0.2"},
      {:plug_cowboy, "~> 2.5"},
      {:plug_probe, "~> 0.1"},

      # i18n
      {:ex_cldr, "~> 2.37"},
      {:gettext, "~> 0.20"},

      # core
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},

      # web
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_view, "~> 0.20.2"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      test: ["ecto.setup", "test"],

      # ! high-level aliases

      # for testing release locally
      "release.local": [
        "assets.setup",
        "assets.deploy",
        "release",
        "assets.clean"
      ],

      # ! group aliases

      "ecto.setup": [
        "core.ecto.setup"
      ],
      "ecto.reset": [
        "core.ecto.reset"
      ],
      "assets.setup": [
        "user_web.assets.setup",
        "admin_web.assets.setup"
      ],
      "assets.build": [
        "user_web.assets.build",
        "admin_web.assets.build"
      ],
      "assets.deploy": [
        "user_web.assets.deploy",
        "admin_web.assets.deploy"
      ],
      "assets.clean": [
        "user_web.assets.clean",
        "admin_web.assets.clean"
      ],

      # ! i18n

      "i18n.gettext.merge": [
        "gettext.extract",
        "gettext.merge priv/i18n/gettext"
      ],
      "i18n.gettext.add_locale": [
        "gettext.merge priv/i18n/gettext --locale"
      ],

      # ! core

      "core.ecto.setup": [
        "ecto.create -r ComboSaaS.Core.Repo",
        "ecto.migrate -r ComboSaaS.Core.Repo",
        "run priv/core/repo/seeds.exs"
      ],
      "core.ecto.reset": [
        "ecto.drop -r ComboSaaS.Core.Repo",
        "core.ecto.setup"
      ],

      # ! user_web

      "user_web.assets.setup": [
        "cmd npm install --prefix assets/user_web"
      ],
      "user_web.assets.build": [
        "cmd npm run build --prefix assets/user_web"
      ],
      "user_web.assets.deploy": [
        "cmd npm run build --prefix assets/user_web",
        "cmd mix phx.digest priv/user_web/static"
      ],
      "user_web.assets.clean": [
        "cmd mix phx.digest.clean --all -o priv/user_web/static"
      ],

      # ! admin_web

      "admin_web.assets.setup": [
        "cmd npm install --prefix assets/admin_web"
      ],
      "admin_web.assets.build": [
        "cmd npm run build --prefix assets/admin_web"
      ],
      "admin_web.assets.deploy": [
        "cmd npm run build --prefix assets/admin_web",
        "cmd mix phx.digest priv/admin_web/static"
      ],
      "admin_web.assets.clean": [
        "cmd mix phx.digest.clean --all -o priv/admin_web/static"
      ]
    ]
  end
end
