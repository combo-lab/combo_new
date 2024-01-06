defmodule NeedleCombo.I18n.Config do
  @moduledoc false

  @compiled_env Application.compile_env!(:needle_combo, NeedleCombo.I18n)
  @default_locale Keyword.fetch!(@compiled_env, :default_locale)
  @locales Keyword.fetch!(@compiled_env, :locales)

  @doc false
  defmacro default_locale() do
    quote do
      unquote(@default_locale)
    end
  end

  @doc false
  defmacro supported_locales() do
    quote do
      unquote(@locales)
    end
  end
end
