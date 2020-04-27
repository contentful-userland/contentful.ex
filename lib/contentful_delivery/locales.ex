defmodule Contentful.Delivery.Locales do
  @moduledoc """
  Handles the fetching of locales within a given `Contentful.Space`
  """
  alias Contentful.{Locale, Queryable}

  @behaviour Queryable

  @endpoint "/locales"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items, "total" => total}) do
    locales =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, locale} -> locale end)

    {:ok, locales, total: total}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "name" => name,
        "code" => code,
        "fallbackCode" => fallback_code,
        "default" => default
      }) do
    {:ok,
     %Locale{
       name: name,
       code: code,
       fallback_code: fallback_code,
       default: default
     }}
  end
end
