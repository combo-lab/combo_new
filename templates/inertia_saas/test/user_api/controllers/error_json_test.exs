defmodule LiveSaaS.UserAPI.ErrorJSONTest do
  use LiveSaaS.UserAPI.ConnCase, async: true

  alias LiveSaaS.UserAPI.ErrorJSON

  test "renders 404" do
    assert ErrorJSON.render("404.json", %{}) == %{message: "Not Found"}
  end

  test "renders 500" do
    assert ErrorJSON.render("500.json", %{}) == %{message: "Internal Server Error"}
  end
end
