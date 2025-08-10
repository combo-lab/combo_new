defmodule ComboLT.Web.ErrorHTMLTest do
  use ComboLT.Web.ConnCase, async: true

  import Combo.Template, only: [render_to_string: 4]
  alias ComboLT.Web.ErrorHTML

  test "renders 404.html" do
    assert render_to_string(ErrorHTML, "404", "html", []) =~ "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ErrorHTML, "500", "html", []) =~ "Internal Server Error"
  end
end
