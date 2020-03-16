defmodule Contentful.Delivery.Assets do
  @moduledoc """
  deals with the loading of assets from a given Contentful.Space

  https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/assets
  """

  alias Contentful.{Asset, Delivery, Space}

  alias HTTPoison.Response

  @doc """
  fetches one asset from a given space

  ## Examples
      space = "my_space_id"
      {:ok, %Asset{} = asset} =  space |>Contentful.Delivery.Assets.fetch_one("<asset_id>")
  """
  @spec fetch_one(String.t() | Space.t(), String.t(), String.t() | nil) ::
          {:ok, Asset.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_one(space, asset, env \\ "master", api_key \\ nil)

  def fetch_one(%Space{meta_data: %{id: space_id}}, asset_id, env, api_key) do
    space_id
    |> build_single_request(asset_id, env, api_key)
    |> Delivery.send_request()
    |> parse_response(&build_asset/1)
  end

  def fetch_one(space_id, asset_id, env, api_key) do
    fetch_one(%Space{meta_data: %{id: space_id}}, asset_id, env, api_key)
  end

  @doc """
  Fetches all assets for a given Contentful.Space

  ## Examples
    space = "my_space_id"
    {:ok, [%Asset{} | _]} = space |> Contentful.Delivery.Assets.fetch_all()
  """
  @spec fetch_all(Space.t() | String.t(), String.t(), String.t() | nil) ::
          {:ok, list(Contentful.Asset.t())}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_all(space, env \\ "master", api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: id}}, env, api_key) do
    id
    |> build_multi_request(env, api_key)
    |> Delivery.send_request()
    |> parse_response(&build_assets/1)
  end

  def fetch_all(space_id, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key)
  end

  defp build_single_request(space, asset, env, api_key) do
    url = [
      Delivery.url(),
      "/spaces/#{space}",
      "/environments/#{env}",
      "/assets/#{asset}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_multi_request(space, env, api_key) do
    url = [
      Delivery.url(),
      "/spaces/#{space}",
      "/environments/#{env}",
      "/assets"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp parse_response(
         {:ok, %Response{status_code: code, body: body} = resp},
         callback
       ) do
    case code do
      200 ->
        body |> Delivery.json_library().decode! |> callback.()

      401 ->
        body |> Delivery.build_error(:unauthorized)

      404 ->
        body |> Delivery.build_error(:not_found)

      _ ->
        resp |> Delivery.build_error()
    end
  end

  defp parse_response({:error, _}, _callback) do
    Delivery.build_error()
  end

  defp build_asset(%{"fields" => fields, "sys" => sys}) do
    {:ok, Asset.from_api_fields(fields, sys)}
  end

  defp build_assets(%{"items" => items}) do
    {:ok, items |> Enum.map(&build_asset/1) |> Enum.map(fn {:ok, asset} -> asset end)}
  end
end
