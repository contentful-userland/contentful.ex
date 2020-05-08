defmodule Contentful.Asset do
  @moduledoc """
  Represents an asset available within a `Contentful.Space`.

  https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/assets
  """

  alias Contentful.{Asset, SysData}
  alias Contentful.Asset.Fields
  defstruct fields: %Fields{}, sys: %SysData{}

  @type t :: %Asset{
          fields: Fields.t(),
          sys: SysData.t()
        }
end
