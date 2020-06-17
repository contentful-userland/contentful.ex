defmodule Contentful.ContentType do
  @moduledoc """
  Describes functions around ContentTypes in a `Contentful.Space`

  See [the official docs](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/content-types) for more information.
  """
  alias Contentful.ContentType.Field
  alias Contentful.{ContentType, SysData}

  defstruct [
    :id,
    :name,
    :description,
    :display_field,
    sys: %SysData{},
    fields: []
  ]

  @typedoc """
    A ContentType is part of the content model defined in a space
  """

  @type t :: %ContentType{
          id: String.t(),
          name: String.t(),
          display_field: String.t(),
          description: String.t(),
          fields: list(Field.t()),
          sys: SysData.t()
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
