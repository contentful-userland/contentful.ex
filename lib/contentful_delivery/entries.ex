defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Collects functions around the reading of entries from a `Contentful.Space`
  """

  alias Contentful.Entry
  alias Contentful.SysData
  alias Contentful.Queryable

  @behaviour Queryable

  @endpoint "/entries"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"total" => total, "items" => items}) do
    entries =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, entry} -> entry end)

    {:ok, entries, total: total}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "fields" => fields,
        "sys" => %{"id" => id, "revision" => rev}
      }) do
    {:ok,
     %Entry{
       fields: fields,
       sys: %SysData{id: id, revision: rev}
     }}
  end
end
