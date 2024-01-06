defmodule ComboSaaS.UserAPI.ErrorJSONTest do
  use ComboSaaS.UserAPI.ConnCase, async: true

  test "renders 404" do
    assert ComboSaaS.UserAPI.ErrorJSON.render("404.json", %{}) ==
             %{message: "Not Found"}
  end

  test "renders 500" do
    assert ComboSaaS.UserAPI.ErrorJSON.render("500.json", %{}) ==
             %{message: "Internal Server Error"}
  end
end
