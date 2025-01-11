# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule InertiaSaaS.UserAPI.MessageJSON do
  @moduledoc false

  def show(%{message: message}) do
    %{message: message}
  end
end
