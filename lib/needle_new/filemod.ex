defmodule Filemod do
  @doc """
  Merges content of two files.
  """
  def merge_file(content, new_content) do
    content_lines = to_lines(content)
    new_content_lines = to_lines(new_content)

    should_merge? =
      Enum.any?(
        new_content_lines,
        fn line -> line not in content_lines end
      )

    if should_merge? do
      content <> "\n" <> new_content
    else
      content
    end
  end

  defp to_lines(content) do
    String.split(content, "\n", trim: true)
  end
end
