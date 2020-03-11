defmodule Contentful.Delivery.ContentTypes do
  @moduledoc """
  Provides functions around reading content types from spaces
  """

  alias Contentful.{ContentType, Delivery, MetaData, Space}
  alias HTTPoison.Response

  @doc """
    Used to query the content types for a given space
  """
  def fetch_all(space, env \\ "master", api_key \\ nil)

  @spec fetch_all(Space.t(), String.t(), String.t() | nil) ::
          {:ok, list(ContentType.t())}
          | {:error, atom(), original_message: String.t()}
  def fetch_all(%Space{meta_data: %{id: id}}, env, api_key) do
    id
    |> build_multiple_request(env, api_key)
    |> Delivery.send_request()
    |> parse_response()
    |> build_content_types()
  end

  @spec fetch_all(String.t(), String.t(), String.t() | nil) ::
          {:ok, list(ContentType.t())}
          | {:error, atom(), original_message: String.t()}
  def fetch_all(space_id, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key)
  end

  @doc """
    Used to fetch a single ContentType
  """
  def fetch_one(content_type_id, space, env \\ "master", api_key \\ nil)

  @spec fetch_one(String.t(), Space.t(), String.t(), String.t() | nil) ::
          {:ok, ContentType.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_one(content_type_id, %Space{meta_data: %{id: id}}, env, api_key) do
    content_type =
      content_type_id
      |> build_single_request(id, env, api_key)
      |> Delivery.send_request()
      |> parse_response()
      |> build_content_type()

    case content_type do
      {:error, _} -> content_type
      content_type -> {:ok, content_type}
    end
  end

  @spec fetch_one(String.t(), String.t(), String.t(), String.t() | nil) ::
          {:ok, ContentType.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_one(content_type_id, space_id, env, api_key) do
    fetch_one(content_type_id, %Space{meta_data: %{id: space_id}}, env, api_key)
  end

  defp build_multiple_request(space_id, environment, api_key) do
    url =
      [
        Delivery.url(),
        "/spaces/#{space_id}",
        "/environments/#{environment}",
        "/content_types"
      ]
      |> Enum.join()

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_single_request(content_type_id, space_id, environment, api_key) do
    url =
      [
        Delivery.url(),
        "/spaces/#{space_id}",
        "/environments/#{environment}",
        "/content_types",
        "/#{content_type_id}"
      ]
      |> Enum.join()

    {url, api_key |> Delivery.request_headers()}
  end

  defp parse_response(response) do
    with {:ok, %Response{status_code: code, body: body}} <- response do
      case code do
        200 ->
          body |> Contentful.json_library().decode!

        401 ->
          body |> Delivery.build_error(:unauthorized)

        404 ->
          body |> Delivery.build_error(:not_found)

        _ ->
          Delivery.build_error(response)
      end
    end
  end

  defp build_content_types(%{"items" => items}) do
    {:ok, items |> Enum.map(&build_content_type/1)}
  end

  defp build_content_type(%{
         "name" => name,
         "description" => description,
         "sys" => %{"id" => id, "revision" => rev}
       }) do
    meta = %MetaData{id: id, revision: rev}

    %ContentType{
      name: name,
      description: description,
      meta_data: meta
    }
  end
end
