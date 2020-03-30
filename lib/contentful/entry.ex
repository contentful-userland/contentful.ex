defmodule Contentful.Entry do
  @moduledoc """
  An entry is a representation of anything that can be expressed as a 
  defined content type within a given `Contentful.Space`.

  See the [official documentation for more information](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/entries).
  """

  alias Contentful.MetaData

  defstruct [:meta_data, fields: []]

  @type t :: %Contentful.Entry{
          fields: list(),
          meta_data: MetaData.t()
        }
end
