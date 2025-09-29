defmodule MyApp.Web.ErrorJSON do
  # If you want to customize a particular status code, you may add your
  # own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end
  #
  # The default is to return the status message from the template name.
  # For example, "404.json" becomes {"errors": {"detail": "Not Found"}}.
  def render(template, _assigns) do
    %{errors: %{detail: Combo.Conn.status_message_from_template(template)}}
  end
end
