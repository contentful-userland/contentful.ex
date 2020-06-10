defmodule Contentful.Delivery.Assets do
  @moduledoc """
  Deals with the loading of assets from a given `Contentful.Space`

  https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/assets
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
        "sys" => %{"id" => id, "revision" => rev}
      }) do
    # title and description optional fields for assets
    title = fields |> Map.get("title", nil)
    desc = fields |> Map.get("description", nil)

    asset = %Asset{
      sys: %SysData{id: id, revision: rev},
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
