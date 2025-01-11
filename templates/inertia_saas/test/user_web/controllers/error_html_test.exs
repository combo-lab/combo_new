defmodule InertiaSaaS.UserWeb.ErrorHTMLTest do
  use InertiaSaaS.UserWeb.ConnCase, async: true

  import Phoenix.Template, only: [render_to_string: 4]
  alias InertiaSaaS.UserWeb.ErrorHTML

  test "renders 404.html" do
    assert render_to_string(ErrorHTML, "404", "html", status: 404) =~ "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ErrorHTML, "500", "html", status: 500) =~ "Internal Server Error"
  end
end
