defmodule NeedleComboUserApi.MessageJSON do
  @moduledoc false

  def show(%{message: message}) do
    %{message: message}
  end
end
