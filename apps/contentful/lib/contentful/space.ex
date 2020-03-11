defmodule Contentful.Space do
  alias Contentful.MetaData
  defstruct [:name, locales: [], meta_data: %MetaData{type: "space"}]

  @typedoc """
    A Space represents a space on contentful.
  """
  @type t(name, locales, meta_data) :: %__MODULE__{
          name: name,
          locales: locales,
          meta_data: meta_data
        }
  @type t :: %Contentful.Space{
          name: String.t(),
          locales: list(),
          meta_data: MetaData.t()
        }
end
