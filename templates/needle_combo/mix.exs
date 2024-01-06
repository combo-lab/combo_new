defmodule NeedleCombo.MixProject do
  use Mix.Project

  def project do
    [
      app: :needle_combo,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {NeedleComboApplication, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:plug_cowboy, "~> 2.5"},
      {:plug_probe, "~> 0.1"},

      # i18n
      {:gettext, "~> 0.20"},
      {:ex_cldr, "~> 2.37"},

      # core
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},

      # web
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.0"},
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
      "ecto.setup": [
        "needle_combo.ecto.setup"
      ],
      "ecto.reset": [
        "needle_combo.ecto.reset"
      ],
      "assets.setup": [
        "needle_combo_user_web.assets.setup",
        "needle_combo_admin_web.assets.setup"
      ],
      "assets.build": [
        "needle_combo_user_web.assets.build",
        "needle_combo_admin_web.assets.build"
      ],
      "assets.deploy": [
        "needle_combo_user_web.assets.deploy",
        "needle_combo_admin_web.assets.deploy"
      ],
      "assets.clean": [
        "needle_combo_user_web.assets.clean",
        "needle_combo_admin_web.assets.clean"
      ],
      # for testing release locally
      "release.local": [
        "assets.setup",
        "assets.deploy",
        "release",
        "assets.clean"
      ],

      # ! i18n

      "i18n.gettext.merge": [
        "gettext.extract",
        "gettext.merge priv/i18n/gettext"
      ],
      "i18n.gettext.add_locale": [
        "gettext.merge priv/i18n/gettext --locale"
      ],

      # ! needle_combo
      "needle_combo.ecto.setup": [
        "ecto.create -r NeedleCombo.Repo",
        "ecto.migrate -r NeedleCombo.Repo",
        "run priv/needle_combo/repo/seeds.exs"
      ],
      "needle_combo.ecto.reset": [
        "ecto.drop -r NeedleCombo.Repo",
        "needle_combo.ecto.setup"
      ],

      # ! needle_combo_user_web
      "needle_combo_user_web.assets.setup": [
        "cmd npm install --prefix assets/needle_combo_user_web"
      ],
      "needle_combo_user_web.assets.build": [
        "cmd npm run build --prefix assets/needle_combo_user_web"
      ],
      "needle_combo_user_web.assets.deploy": [
        "cmd npm run build --prefix assets/needle_combo_user_web",
        "cmd mix phx.digest priv/needle_combo_user_web/static"
      ],
      "needle_combo_user_web.assets.clean": [
        "cmd mix phx.digest.clean --all -o priv/needle_combo_user_web/static"
      ],

      # ! needle_combo_admin_web

      "needle_combo_admin_web.assets.setup": [
        "cmd npm install --prefix assets/needle_combo_admin_web"
      ],
      "needle_combo_admin_web.assets.build": [
        "cmd npm run build --prefix assets/needle_combo_admin_web"
      ],
      "needle_combo_admin_web.assets.deploy": [
        "cmd npm run build --prefix assets/needle_combo_admin_web",
        "cmd mix phx.digest priv/needle_combo_admin_web/static"
      ],
      "needle_combo_admin_web.assets.clean": [
        "cmd mix phx.digest.clean --all -o priv/needle_combo_admin_web/static"
      ]
    ]
  end
end
