defmodule Contentful.ContentType do
  defstruct [
    :name,
    :description,
    meta_data: %Contentful.MetaData{}
  ]

  @typedoc """
    A ContentType is part of the content model defined in a space
  """

  @type t :: %Contentful.ContentType{
          name: String.t(),
          description: String.t(),
          meta_data: Contentful.MetaData.t()
        }
end
