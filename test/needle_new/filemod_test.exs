defmodule FilemodTest do
  use ExUnit.Case

  describe "merge_file/2" do
    test "merges new content" do
      content = """
      # The directory Mix will write compiled artifacts to.
      /_build/

      # If you run "mix test --cover", coverage assets end up here.
      /cover/
      """

      new_content = """
      # The directory Mix downloads the dependencies sources to.
      /deps/

      # Where 3rd-party dependencies like ExDoc output generated docs.
      /doc/
      """

      assert Filemod.merge_file(content, new_content) == """
             # The directory Mix will write compiled artifacts to.
             /_build/

             # If you run "mix test --cover", coverage assets end up here.
             /cover/

             # The directory Mix downloads the dependencies sources to.
             /deps/

             # Where 3rd-party dependencies like ExDoc output generated docs.
             /doc/
             """
    end

    test "skips existing content" do
      content = """
      # The directory Mix will write compiled artifacts to.
      /_build/

      # If you run "mix test --cover", coverage assets end up here.
      /cover/
      """

      new_content = """
      # If you run "mix test --cover", coverage assets end up here.
      /cover/
      """

      assert Filemod.merge_file(content, new_content) == """
             # The directory Mix will write compiled artifacts to.
             /_build/

             # If you run "mix test --cover", coverage assets end up here.
             /cover/
             """
    end
  end
end
