defmodule NeedleNew.CodemodTest do
  use ExUnit.Case, async: true

  alias NeedleNew.Codemod

  describe "inject_deps/2" do
    test "appends new deps directly" do
      source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project

        def project do
          [
            app: :demo,
            version: "0.1.0",
            elixir: "~> 1.15",
            start_permanent: Mix.env() == :prod,
            deps: deps()
          ]
        end

        # Run "mix help deps" to learn about dependencies.
        defp deps do
          [
            # {:dep_from_hexpm, "~> 0.3.0"},
            # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
            {:a, "~> 1.0"}
          ]
        end
      end
      """

      new_source = ~S"""
      [
        {:jason, "~> 1.2"},
        {:dns_cluster, "~> 0.1.1"}
      ]
      """

      assert Codemod.inject_deps(source, new_source) ==
               String.trim(~S"""
               defmodule Demo.MixProject do
                 use Mix.Project

                 def project do
                   [
                     app: :demo,
                     version: "0.1.0",
                     elixir: "~> 1.15",
                     start_permanent: Mix.env() == :prod,
                     deps: deps()
                   ]
                 end

                 # Run "mix help deps" to learn about dependencies.
                 defp deps do
                   [
                     # {:dep_from_hexpm, "~> 0.3.0"},
                     # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
                     {:a, "~> 1.0"},
                     {:jason, "~> 1.2"},
                     {:dns_cluster, "~> 0.1.1"}
                   ]
                 end
               end
               """)
    end
  end

  describe "inject_aliases/2" do
    test "appends new deps directly" do
      source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project

        def project do
          [
            app: :demo,
            version: "0.1.0",
            elixir: "~> 1.15",
            start_permanent: Mix.env() == :prod,
            aliases: aliases()
          ]
        end

        defp aliases do
          [
            setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"]
          ]
        end
      end
      """

      new_source = ~S"""
      [
        # ! demo_user_web

        "demo_user_web.assets.setup": [
          "cmd npm install --prefix assets/demo_user_web"
        ],
        "demo_user_web.assets.build": [
          "cmd npm run build --prefix assets/demo_user_web"
        ],
        "demo_user_web.assets.deploy": [
          "cmd npm run build --prefix assets/demo_user_web",
          "cmd mix phx.digest priv/demo_user_web/static"
        ],
        "demo_user_web.assets.clean": [
          "cmd mix phx.digest.clean --all -o priv/demo_user_web/static"
        ]
      ]
      """

      assert Codemod.inject_aliases(source, new_source) ==
               String.trim(~S"""
               defmodule Demo.MixProject do
                 use Mix.Project

                 def project do
                   [
                     app: :demo,
                     version: "0.1.0",
                     elixir: "~> 1.15",
                     start_permanent: Mix.env() == :prod,
                     aliases: aliases()
                   ]
                 end

                 defp aliases do
                   [
                     setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],

                     # ! demo_user_web

                     "demo_user_web.assets.setup": [
                       "cmd npm install --prefix assets/demo_user_web"
                     ],
                     "demo_user_web.assets.build": [
                       "cmd npm run build --prefix assets/demo_user_web"
                     ],
                     "demo_user_web.assets.deploy": [
                       "cmd npm run build --prefix assets/demo_user_web",
                       "cmd mix phx.digest priv/demo_user_web/static"
                     ],
                     "demo_user_web.assets.clean": [
                       "cmd mix phx.digest.clean --all -o priv/demo_user_web/static"
                     ]
                   ]
                 end
               end
               """)
    end
  end

  describe "inject_config/2" do
    test "appends new config directly" do
      source = ~S"""
      # An example config

      # Configure Logger
      config :logger, :console, metadata: [:request_id]
      """

      new_source = ~S"""
      # Use Jason for JSON parsing in Phoenix
      config :phoenix, :json_library, Jason
      """

      assert Codemod.inject_config(source, new_source) ==
               String.trim(~S"""
               # An example config

               # Configure Logger
               config :logger, :console, metadata: [:request_id]

               # Use Jason for JSON parsing in Phoenix
               config :phoenix, :json_library, Jason
               """)
    end

    test "inserts new config before import_config call" do
      source = ~S"""
      # An example config

      # Configure Logger
      config :logger, :console, metadata: [:request_id]

      # Import environment specific config. This must remain at the bottom of this
      # file so it overrides the configuration defined above.
      import_config "#{config_env()}.exs"
      """

      new_source = ~S"""
      # Use Jason for JSON parsing in Phoenix
      config :phoenix, :json_library, Jason
      """

      assert Codemod.inject_config(source, new_source) ==
               String.trim(~S"""
               # An example config

               # Configure Logger
               config :logger, :console, metadata: [:request_id]

               # Use Jason for JSON parsing in Phoenix
               config :phoenix, :json_library, Jason

               # Import environment specific config. This must remain at the bottom of this
               # file so it overrides the configuration defined above.
               import_config "#{config_env()}.exs"
               """)
    end
  end
end
