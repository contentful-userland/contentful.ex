defmodule Contentful.Delivery.Assets do
  @moduledoc """
  Deals with the loading of assets from a given `Contentful.Space`

  See https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/assets.end

  ## Simple asset calls

  A `Contentful.Asset` can be retrieved by its `asset_id`:

    import Contentful.Query
    alias Contentful.Asset
    alias Contentful.Delivery.Assets

    {:ok, %Asset{id: "my_asset_id"}} = Assets |> fetch_one("my_asset_id")

  or just as a collection:

    import Contentful.Query
    alias Contentful.Asset
    alias Contentful.Delivery.Assets

    {:ok, [%Asset{id: "my_asset_id"} | _ ]} = Assets |> fetch_all

  ## Resolving assets from entries

  In the case of inclusion of assets with entries, see the docs for `Contentful.Entries` to see how to resolve assets
  from entries.

  ## Accessing common resource attributes

  A `Contentful.Asset` embeds `Contentful.SysData` with extra information about the entry:

    import Contentful.Query
    alias Contentful.Asset
    alias Contentful.Delivery.Assets

    {:ok, asset} = Assets |> fetch_one("my_asset_id")

    "my_asset_id" = asset.id
    "<a timestamp for updated_at>" = asset.sys.updated_at
    "<a timestamp for created_at>" = asset.sys.created_at
    "<a locale string>" = asset.sys.locale

  """

  alias Contentful.{Asset, Queryable, SysData}

  @behaviour Queryable

  @endpoint "/assets"

  @doc """
  Returns the endpoint for assets
  """
  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_entity_response(%{
        "fields" =>
          %{
            "file" => %{
              "contentType" => content_type,
              "details" => details,
              "fileName" => file_name,
              "url" => url
            }
          } = fields,
        "sys" => %{
          "id" => id,
          "revision" => rev,
          "createdAt" => created_at,
          "updatedAt" => updated_at,
          "locale" => locale
        }
      }) do
    # title and description optional fields for assets
    title = fields |> Map.get("title", nil)
    desc = fields |> Map.get("description", nil)

    asset = %Asset{
      sys: %SysData{
        id: id,
        revision: rev,
        created_at: created_at,
        updated_at: updated_at,
        locale: locale
      },
      fields: %Asset.Fields{
        title: title,
        description: desc,
        file: %{
          content_type: content_type,
          url: URI.parse(url),
          file_name: file_name,
          details: details
        }
      }
    }

    {:ok, asset}
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items, "total" => total}) do
    assets =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, asset} -> asset end)

    {:ok, assets, total: total}
  end
end
