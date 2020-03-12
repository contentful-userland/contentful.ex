defmodule Contentful.ContentType do
  alias Contentful.MetaData
  alias Contentful.ContentType.Field

  defstruct [
    :name,
    :description,
    meta_data: %MetaData{},
    fields: []
  ]

  @typedoc """
    A ContentType is part of the content model defined in a space
  """

  @type t :: %Contentful.ContentType{
          name: String.t(),
          description: String.t(),
          fields: list(Field.t()),
          meta_data: MetaData.t()
        }
end
