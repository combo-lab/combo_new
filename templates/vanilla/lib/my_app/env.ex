defmodule MyApp.Env do
  @moduledoc false

  @mix_env Mix.env()

  def current, do: @mix_env
  def dev?, do: @mix_env == :dev
  def prod?, do: @mix_env == :prod
end
