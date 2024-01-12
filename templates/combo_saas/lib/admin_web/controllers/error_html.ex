defmodule ComboSaaS.AdminWeb.ErrorHTML do
  @moduledoc """
  Provides HTML error pages.

  If you want to customize the error pages for particular status codes, add
  pages to the `error_html/` directory, such as:

    * lib/admin_web/controllers/error_html/404.html.heex
    * lib/admin_web/controllers/error_html/500.html.heex

  Or, add `render/2` functions, such as:

      def render("404.html", assigns) do
        # ...
      end

      def render("500.html", assigns) do
        # ...
      end

  """

  use ComboSaaS.AdminWeb, :html
  require Logger

  embed_templates "error_html/*"

  def render(template, assigns) do
    message = get_message_from_template_name(template)
    assigns = Map.put(assigns, :message, message)
    fallback(assigns)
  end

  defp get_message_from_template_name(template) do
    template
    |> Phoenix.Controller.status_message_from_template()
    |> translate_status_message()
  end

  defp translate_status_message("Bad Request") do
    dgettext("http_status_messages", "Bad Request")
  end

  defp translate_status_message("Not Found") do
    dgettext("http_status_messages", "Not Found")
  end

  defp translate_status_message("Internal Server Error") do
    dgettext("http_status_messages", "Internal Server Error")
  end

  defp translate_status_message(error) do
    Logger.warning("unhandled server error - #{error}")
    dgettext("http_status_messages", "Something Went Wrong")
  end
end
