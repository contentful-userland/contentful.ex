defmodule Contentful.MetaData do
  defstruct [:id, :revision]

  @typedoc """
    The MetaData represents internal additional data for Contetnful API objects, usually found in the 
    "sys" part of the response objects.
  """
  @type t :: %Contentful.MetaData{
          id: String.t(),
          revision: integer()
        }
end
