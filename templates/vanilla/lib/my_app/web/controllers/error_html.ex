defmodule MyApp.Web.ErrorHTML do
  use MyApp.Web, :html

  # If you want to customize your error pages, uncomment the embed_templates/1
  # call below and add pages to the error directory:
  #
  #   * lib/web/controllers/error_html/404.html.ceex
  #   * lib/web/controllers/error_html/500.html.ceex
  #
  # embed_templates "error_html/*"
  #
  # The default is to render a plain text page based on the template name.
  # For example, "404.html" becomes "Not Found".
  def render(template, _assigns) do
    Combo.Conn.status_message_from_template(template)
  end
end
