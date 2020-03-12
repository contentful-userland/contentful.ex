defmodule Contentful.ContentType.Field do
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
