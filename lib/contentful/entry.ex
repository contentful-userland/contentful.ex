defmodule Contentful.Entry do
  @moduledoc """
  An entry is a representation of anything that can be expressed as a
  defined content type within a given `Contentful.Space`.

  See the [official documentation for more information](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/entries).
  """

  alias Contentful.SysData
  alias Contentful.Metadata

  defstruct [:sys, fields: [], metadata: %Metadata{}]

  @type t :: %Contentful.Entry{
          fields: list(),
          sys: SysData.t(),
          metadata: Metadata.t()
        }
end
