defmodule NeedleComboUserApi.ErrorJSON do
  require Logger
  import I18n.Gettext

  @doc """
  Fallback rendering logic for errors.

  If you want to customize a particular status code, you can add your own
  clauses, such as:

      def render("500.json", _assigns) do
        %{message: "Oops, something goes wrong."}
      end

  """
  def render(template, _assigns) do
    message = get_message_from_template_name(template)
    %{message: message}
  end

  # Get the HTTP status message from the template name.
  #
  # For example:
  # + "401.json" - "Unauthorized"
  # + "404.json" - "Not found"
  # + "500.json" - "Internal Server Error"
  #
  defp get_message_from_template_name(template) do
    template
    |> Phoenix.Controller.status_message_from_template()
    |> translate_error()
  end

  defp translate_error("Bad Request") do
    dgettext("http_errors", "Bad Request")
  end

  defp translate_error("Not Found") do
    dgettext("http_errors", "Not Found")
  end

  defp translate_error("Internal Server Error") do
    dgettext("http_errors", "Internal Server Error")
  end

  defp translate_error(error) do
    Logger.warning("unhandled server error - #{error}")
    dgettext("http_errors", "Internal Server Error")
  end
end
