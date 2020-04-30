defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Collects functions around the reading of entries from a `Contentful.Space`
  """

  alias Contentful.{Asset, Entry, Queryable, SysData}
  alias Contentful.Delivery.Assets
  alias Contentful.Entry.AssetResolver

  @behaviour Queryable

  @endpoint "/entries"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @doc """
  specifies the collection resolver for the case when assets are included within the entries response
  """
  def resolve_collection_response(%{
        "total" => total,
        "items" => items,
        "includes" => %{"Asset" => assets}
      }) do
    {:ok, entries, total: total} =
      resolve_collection_response(%{"total" => total, "items" => items})

    resolved_entries =
      entries
      |> Enum.map(fn entry ->
        asset_ids = entry |> AssetResolver.find_linked_asset_ids()

        assets_for_entry =
          assets
          |> Enum.map(&Assets.resolve_entity_response/1)
          |> Enum.map(fn {:ok, asset} -> asset end)
          |> Enum.filter(fn %Asset{sys: %SysData{id: id}} -> asset_ids |> Enum.member?(id) end)

        entry |> Map.put(:assets, assets_for_entry)
      end)

    {:ok, resolved_entries, total: total}
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
