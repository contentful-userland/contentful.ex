defmodule Contentful.Delivery.Assets do
  @moduledoc """
  deals with the loading of assets from a given Contentful.Space

  https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/assets
  """

  alias Contentful.{Asset, Collection, CollectionStream, Delivery, Space}

  @behaviour Collection
  @behaviour CollectionStream
  @doc """
  fetches one asset from a given space

  ## Examples
      space = "my_space_id"
      {:ok, %Asset{} = asset} =  space |>Contentful.Delivery.Assets.fetch_one("<asset_id>")
  """
  @impl Collection
  def fetch_one(space, asset, env \\ "master", api_key \\ nil)

  def fetch_one(%Space{meta_data: %{id: space_id}}, asset_id, env, api_key) do
    space_id
    |> build_single_request(asset_id, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_asset/1)
  end

  def fetch_one(space_id, asset_id, env, api_key) do
    fetch_one(%Space{meta_data: %{id: space_id}}, asset_id, env, api_key)
  end

  @doc """
  Fetches all assets for a given `Contentful.Space`.

  Will take basic collection filters into account, specifically :limit and :skip to traverse and 
  limit the collection of assets.

  ## Examples
      space = "my_space_id"
      {:ok, [%Asset{} | _]} = space |> Assets.fetch_all()

      {:ok, [
        %Asset{ meta_data: %{ id: "foobar_0"}}, 
        %Asset{ meta_data: %{ id: "foobar_1"}}, 
        %Asset{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Assets.fetch_all
      
      {:ok, [
        %Asset{ meta_data: %{ id: "foobar_1"}}, 
        %Asset{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Assets.fetch_all(skip: 1)

      {:ok, [
        %Asset{ meta_data: %{ id: "foobar_0"}}
      ], total: 3} = space |> Assets.fetch_all(limit: 1)

      {:ok, [
        %Asset{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Assets.fetch_all(limit: 1, skip: 2)
  """
  @impl Collection
  def fetch_all(space, options \\ [], env \\ "master", api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: id}}, options, env, api_key) do
    id
    |> build_multi_request(options, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_assets/1)
  end

  def fetch_all(space_id, options, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, options, env, api_key)
  end

  @doc """
  Constructs a stream around __all__ assets of a `Contentful.Space` __that are published__.

  Will return a stream of assets that can be composed with the standard libraries functions. 
  This function calls the API endpoint for entries on demand, e.g. until the upper limit 
  (the total of all assets) is reached.

  __Warning__: With very large asset collections, this can quickly run into the request limit of the API! 

  ## Examples
      space = "my_space_id"
      # API calls calculated by the stream (in this case two calls)
      ["first_asset_id", "second_asset_id"] 
        = space 
          |> Assets.stream(limit: 1) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(2) 

      environment = "staging"
      api_token = "foobar?foob4r"
      ["first_asset_id"] 
        = space 
          |> Assets.stream(limit: 1, environment, api_token) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(2) 
    
      # Use the :limit parameter to set the page size 
      ["first_asset_id", "second_asset_id", "third_asset_id", "fourth_asset_id"] 
        = space 
          |> Assets.stream(limit: 4) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(4) 
  """
  @impl CollectionStream
  def stream(space, options \\ [], env \\ "master", api_key \\ nil) do
    space |> CollectionStream.stream_all(&fetch_all/4, options, env, api_key)
  end

  defp build_single_request(space, asset, env, api_key) do
    url = [
      Delivery.url(space, env),
      "/assets/#{asset}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_multi_request(space, options, env, api_key) do
    url = [
      Delivery.url(space, env),
      "/assets",
      Delivery.collection_query_params(options)
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_asset(%{"fields" => fields, "sys" => sys}) do
    {:ok, Asset.from_api_fields(fields, sys)}
  end

  defp build_assets(%{"items" => items, "total" => total}) do
    assets =
      items
      |> Enum.map(&build_asset/1)
      |> Enum.map(fn {:ok, asset} -> asset end)

    {:ok, assets, total: total}
  end
end
