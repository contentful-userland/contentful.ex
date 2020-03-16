defmodule Contentful.Locale do
  @moduledoc """
  Represents a single locale available in a given Space - see

  https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/locales
  """

  defstruct [:name, :code, :fallback_code]

  alias Contentful.Locale

  @type t :: %Locale{
          name: String.t(),
          code: String.t(),
          fallback_code: String.t() | nil
        }
end
