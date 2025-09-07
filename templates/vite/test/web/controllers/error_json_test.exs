defmodule DemoLT.Web.ErrorJSONTest do
  use DemoLT.Web.ConnCase, async: true

  alias DemoLT.Web.ErrorJSON

  test "renders 404" do
    assert ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ErrorJSON.render("500.json", %{}) == %{errors: %{detail: "Internal Server Error"}}
  end
end
