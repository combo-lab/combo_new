# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ComboSaaS.UserAPI.ErrorJSON do
  @moduledoc """
  Provides JSON error responses.

  If you want to customize a particular status code, you can `render/2`
  functions, such as:

      def render("500.json", _assigns) do
        %{message: "Oops, something went wrong."}
      end

  """

  import ComboSaaS.I18n.Gettext
  require Logger

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
