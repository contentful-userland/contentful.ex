defmodule Contentful.ContentType.Field do
  @moduledoc """
  Represents a single field in the field defintion of a `Contentful.ContentType`.

  See the [content model documentation for more information](https://www.contentful.com/developers/docs/concepts/data-model/)

  """
  defstruct [
    :name,
    :type,
    :localized,
    :required,
    :disabled,
    :omitted,
    validations: []
  ]

  @type t :: %Contentful.ContentType.Field{
          name: String.t(),
          type: String.t(),
          localized: boolean(),
          required: boolean(),
          disabled: boolean(),
          omitted: boolean()
        }
end
