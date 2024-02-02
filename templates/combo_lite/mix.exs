defmodule ComboLite.MixProject do
  use Mix.Project

  @app :combo_lite
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
      boundary: boundary(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ComboLite.Application, []},
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

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cozy_telemetry, "~> 0.5"},
      {:dns_cluster, "~> 0.1.1"},
      {:jason, "~> 1.2"},
      {:cozy_proxy, "~> 0.3"},
      {:bandit, "~> 1.2"},
      {:cozy_env, "~> 0.2"},
      {:plug_probe, "~> 0.1"},

      # i18n
      {:ex_cldr, "~> 2.37"},
      {:gettext, "~> 0.20"},

      # web
      {:phoenix, "~> 1.7.11"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 0.20.2"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:cozy_svg, "~> 0.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:floki, ">= 0.30.0", only: :test},

      # code quality
      {:boundary, "~> 0.10", runtime: false},
      {:ex_check, "~> 0.15.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev], runtime: false}
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
            # warn the runtime calls of Mix, which is not available in release
            {:mix, :runtime}
          ]
        ]
      ]
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],

      # ! high-level aliases

      # for testing release locally
      "release.local": [
        "assets.setup",
        "assets.deploy",
        "release",
        "assets.clean"
      ],

      # ! group aliases

      "assets.setup": [
        "user_web.assets.setup"
      ],
      "assets.build": [
        "user_web.assets.build"
      ],
      "assets.deploy": [
        "user_web.assets.deploy"
      ],
      "assets.clean": [
        "user_web.assets.clean"
      ],

      #! i18n

      "i18n.gettext.merge": [
        "gettext.extract",
        "gettext.merge priv/i18n/gettext"
      ],
      "i18n.gettext.add_locale": [
        "gettext.merge priv/i18n/gettext --locale"
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
      ]
    ]
  end
end
