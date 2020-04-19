defmodule Contentful.Space do
  defstruct [:name, sys: %Contentful.SysData{}]

  @moduledoc """
  A Space represents a space on contentful, holding most of the objects you work with, e.g. `Contentful.Asset`, `Contentful.Entry` or `Contentful.Locale`

  See the [official documentation for more information](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/spaces)
  """
  @type t :: %Contentful.Space{
          name: String.t(),
          sys: Contentful.SysData.t()
        }
end
