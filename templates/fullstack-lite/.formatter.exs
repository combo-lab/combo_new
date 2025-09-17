[
  import_deps: [:combo, :ecto, :ecto_sql],
  subdirectories: ["priv/*/migrations"],
  plugins: [Combo.HTML.Formatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs,ceex}",
    "priv/*/seeds.exs"
  ]
]
