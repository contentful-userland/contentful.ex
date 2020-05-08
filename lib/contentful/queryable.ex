defmodule Contentful.Queryable do
  @moduledoc """
  Behaviour for allowing another module to be processed by the functions
  of `Contentful.Query`.

  See also:
    * `Contentful.Delivery.Assets`
    * `Contentful.Delivery.ContentTypes`
    * `Contentful.Delivery.Entries`
    * `Contentful.Delivery.Locales`
    * `Contentful.Delivery.Spaces`
  """
  @callback endpoint() :: String.t()
  @callback resolve_collection_response(%{
              required(total: String.t()) => non_neg_integer(),
              required(items: String.t()) => [...]
            }) ::
              {:ok, list(struct()), total: non_neg_integer()}
  @callback resolve_entity_response(map()) :: {:ok, struct()}
end
