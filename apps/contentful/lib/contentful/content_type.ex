defmodule Contentful.ContentType do
  alias Contentful.{ContentType, MetaData}
  alias Contentful.ContentType.Field

  defstruct [
    :name,
    :description,
    :display_field,
    meta_data: %MetaData{},
    fields: []
  ]

  @typedoc """
    A ContentType is part of the content model defined in a space
  """

  @type t :: %ContentType{
          name: String.t(),
          display_field: String.t(),
          description: String.t(),
          fields: list(Field.t()),
          meta_data: MetaData.t()
        }

  @doc """
  returns the display field for a given content type

  ## Examples
      content_type = %ContentType{display_field: "name", fields: [%ContentType.Field{name: "name"}]}

      # extracts the display field from the content type
      %ContentType.Field{name: "name"} = content_type |> ContentType.display_field
  """
  @spec display_field(ContentType.t()) :: Field.t()
  def display_field(%ContentType{
        display_field: display_field,
        fields: fields
      }),
      do: fields |> Enum.find(fn %Field{name: name} -> name == display_field end)
end
