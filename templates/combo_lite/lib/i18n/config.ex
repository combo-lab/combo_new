defmodule ComboLite.I18n.Config do
  @moduledoc false

  @compiled_env Application.compile_env!(:combo_lite, ComboLite.I18n)
  @locales Keyword.fetch!(@compiled_env, :locales)
  @default_locale Keyword.fetch!(@compiled_env, :default_locale)

  @doc false
  defmacro locales do
    quote do
      unquote(@locales)
    end
  end

  @doc false
  defmacro default_locale do
    quote do
      unquote(@default_locale)
    end
  end
end
