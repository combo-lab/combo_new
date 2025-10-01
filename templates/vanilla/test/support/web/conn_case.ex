defmodule MyApp.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by tests that require setting
  up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint MyApp.Web.Endpoint

      use MyApp.Web, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Combo.ConnTest
      import MyApp.Web.ConnCase
    end
  end

  setup _tags do
    {:ok, conn: Combo.ConnTest.build_conn()}
  end
end
