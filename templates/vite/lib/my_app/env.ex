defmodule MyApp.Env do
  @moduledoc false

  @mix_env Mix.env()

  def current, do: @mix_env

  @dialyzer {:nowarn_function, dev?: 0}
  def dev?, do: @mix_env == :dev

  @dialyzer {:nowarn_function, prod?: 0}
  def prod?, do: @mix_env == :prod

  @dialyzer {:nowarn_function, test?: 0}
  def test?, do: @mix_env == :test
end
