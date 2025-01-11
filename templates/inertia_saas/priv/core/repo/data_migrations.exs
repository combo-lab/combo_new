data_migrations = []

Enum.each(data_migrations, fn file ->
  Code.eval_file(file, Path.join(__DIR__, "./data_migrations"))
end)
