defmodule Contentful.SysData do
  @moduledoc """
  The SysData represents internal additional data for Contentful API objects, usually found in the
  "sys" part of the response objects. It's also referred to as "common properties".

  See the [official documentation for more information](https://www.contentful.com/developers/docs/references/content-delivery-api/#/introduction/common-resource-attributes).
  """
  defstruct [
    :id,
    :revision,
    :created_at,
    :updated_at,
    locale: nil,
    content_type: nil
  ]

  @type t :: %Contentful.SysData{
          id: String.t(),
          # NOTE: revision only exists in Entry, Asset, ContentType
          revision: integer() | nil,
          # NOTE: timestamps only exists in Asset, Entry and ContentType
          created_at: String.t() | nil,
          updated_at: String.t() | nil,
          # NOTE: locale string only exists in Entry and Asset
          locale: String | nil,
          # NOTE: ContentType only exists in Entry
          content_type: String.t() | nil
        }
end
