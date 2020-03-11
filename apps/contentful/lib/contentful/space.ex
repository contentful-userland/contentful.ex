defmodule Contentful.Space do
  defstruct [:name, meta_data: %Contentful.MetaData{}]

  @typedoc """
    A Space represents a space on contentful.
  """
  @type t :: %Contentful.Space{
          name: String.t(),
          meta_data: Contentful.MetaData.t()
        }
end
