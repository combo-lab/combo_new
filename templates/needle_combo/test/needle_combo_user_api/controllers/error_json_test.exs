defmodule NeedleComboUserAPI.ErrorJSONTest do
  use NeedleComboUserAPI.ConnCase, async: true

  test "renders 404" do
    assert NeedleComboUserAPI.ErrorJSON.render("404.json", %{}) ==
             %{message: "Not Found"}
  end

  test "renders 500" do
    assert NeedleComboUserAPI.ErrorJSON.render("500.json", %{}) ==
             %{message: "Internal Server Error"}
  end
end
