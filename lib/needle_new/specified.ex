defprotocol NeedleNew.Specified do
  @doc "Returns the binding of a given spec."
  def get_binding(spec)

  @doc "Returns the specific path of a given spec."
  def get_path!(spec, path_name)
end
