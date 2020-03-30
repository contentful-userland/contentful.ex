defmodule Contentful.Asset.Fields do
  @moduledoc """
  Represents the fields of an asset, which can very depending on the asset.
  """

  alias Contentful.Asset.Fields

  defstruct [
    :title,
    :description,
    file: %{content_type: "", file_name: "", url: %URI{}, details: %{}}
  ]

  @type t :: %Fields{
          title: String.t(),
          description: String.t(),
          file: %{
            file_name: String.t(),
            url: URI.t(),
            details: map()
          }
        }
end
