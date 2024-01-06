defmodule I18n.Config do
  @moduledoc false

  @compiled_env Application.compile_env!(:needle_combo, I18n)
  @default_locale Keyword.fetch!(@compiled_env, :default_locale)
  @locales Keyword.fetch!(@compiled_env, :locales)

  @doc false
  def default_locale(), do: @default_locale

  @doc false
  def locales(), do: @locales
end
