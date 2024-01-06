defmodule NeedleNew.CodemodTest do
  use ExUnit.Case, async: true

  require NeedleNew.Codemod
  alias NeedleNew.Codemod

  describe "extract_pattern_var/3" do
    setup do
      source = ~S"""
      defmodule Demo.MixProject do
        defp deps do
           [
             {:a, "~> 1.0"}
           ]
         end
      end
      """

      ast = Sourceror.parse_string!(source)
      [ast: ast]
    end

    test "succeeds to extract var from pattern", %{ast: ast} do
      extracted =
        Codemod.extract_pattern_var(
          ast,
          {:defp, _,
           [
             {:deps, _, _},
             [
               {
                 {_, _, [:do]},
                 {:__block__, _, [deps]}
               }
             ]
           ]},
          deps
        )

      expected = [
        {:__block__,
         [
           trailing_comments: [],
           leading_comments: [],
           closing: [line: 4, column: 21],
           line: 4,
           column: 8
         ],
         [
           {{:__block__, [trailing_comments: [], leading_comments: [], line: 4, column: 9], [:a]},
            {:__block__,
             [
               trailing_comments: [],
               leading_comments: [],
               delimiter: "\"",
               line: 4,
               column: 13
             ], ["~> 1.0"]}}
         ]}
      ]

      assert extracted == expected
    end

    test "fails to extract var from pattern", %{ast: ast} do
      extracted =
        Codemod.extract_pattern_var(
          ast,
          {:unknown, _, args},
          args
        )

      assert extracted == nil
    end
  end

  test "get_module_name!/1" do
    source = ~S"""
    defmodule Demo.MixProject do
    end
    """

    assert Demo.MixProject ==
             source
             |> Sourceror.parse_string!()
             |> Codemod.get_module_name!()
  end

  describe "merge_mix/2" do
    setup do
      source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project

        def project do
          [
            app: :demo,
            version: "0.1.0",
            elixir: "~> 1.15",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            aliases: aliases()
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

        defp aliases do
          [
            setup: [ "deps.get" ]
          ]
        end
      end
      """

      [source: source]
    end

    test "merges deps and aliases", %{source: source} do
      new_source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project

        # Run "mix help deps" to learn about dependencies.
        defp deps do
          [
            {:b, "~> 1.0"}
          ]
        end

        defp aliases do
          [
            # demo_user_web
            "demo_user_web.assets.setup": [
              "cmd npm install --prefix assets/demo_user_web"
            ]
          ]
        end
      end
      """

      assert Codemod.merge_mix(source, new_source) == """
             defmodule Demo.MixProject do
               use Mix.Project

               def project do
                 [
                   app: :demo,
                   version: "0.1.0",
                   elixir: "~> 1.15",
                   start_permanent: Mix.env() == :prod,
                   deps: deps(),
                   aliases: aliases()
                 ]
               end

               # Run "mix help deps" to learn about dependencies.
               defp deps do
                 [
                   # {:dep_from_hexpm, "~> 0.3.0"},
                   # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
                   {:a, "~> 1.0"},
                   {:b, "~> 1.0"}
                 ]
               end

               defp aliases do
                 [
                   setup: ["deps.get"],

                   # demo_user_web
                   "demo_user_web.assets.setup": [
                     "cmd npm install --prefix assets/demo_user_web"
                   ]
                 ]
               end
             end
             """
    end

    test "merges deps only when they are provided", %{source: source} do
      new_source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project
      end
      """

      assert Codemod.merge_mix(source, new_source) == """
             defmodule Demo.MixProject do
               use Mix.Project

               def project do
                 [
                   app: :demo,
                   version: "0.1.0",
                   elixir: "~> 1.15",
                   start_permanent: Mix.env() == :prod,
                   deps: deps(),
                   aliases: aliases()
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

               defp aliases do
                 [
                   setup: ["deps.get"]
                 ]
               end
             end
             """
    end

    test "merges aliases only when they are provided", %{source: source} do
      new_source = ~S"""
      defmodule Demo.MixProject do
        use Mix.Project
      end
      """

      assert Codemod.merge_mix(source, new_source) == """
             defmodule Demo.MixProject do
               use Mix.Project

               def project do
                 [
                   app: :demo,
                   version: "0.1.0",
                   elixir: "~> 1.15",
                   start_permanent: Mix.env() == :prod,
                   deps: deps(),
                   aliases: aliases()
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

               defp aliases do
                 [
                   setup: ["deps.get"]
                 ]
               end
             end
             """
    end
  end

  describe "merge_config/2" do
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

      assert Codemod.merge_config(source, new_source) ==
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

      assert Codemod.merge_config(source, new_source) ==
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
