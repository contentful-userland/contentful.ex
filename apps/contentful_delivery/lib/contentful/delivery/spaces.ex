defmodule Contentful.Delivery.Spaces do
  @moduledoc """
  Spaces provides function related to the reading of spaces 
  through the Contentful Delivery API
  """

  alias Contentful.{Delivery, MetaData, Space}

  import Contentful.Delivery, only: [json_library: 0]
  alias HTTPoison.Response

  @doc """
  fetch_one() will retrieve one space by it's space id

  ## Examples

      # space you have access to, token will be read from config/config.exs
      iex> {:ok, space} = Contentful.Delivery.Spaces.fetch_one("space_id")
      {:ok, %Contentful.Space{name: "a space name", meta_data: %{id: "space_id"}}}

      # space that does not exist
      iex> {:error, :not_found, original_message: _message} 
        = Contentful.Delivery.Spaces.fetch_one("non_existing_space", "<your_api_key>")

      # no access
      iex> {:error, :unauthorized, original_message: _message} 
        = Contentful.Delivery.Spaces.fetch_one("non_existing_space", "<your_api_key>")
  """
  @spec fetch_one(String.t(), String.t()) ::
          {:ok, Space.t()}
          | {:error, atom(), list(keyword())}
          | {:error, :unknown}
  def fetch_one(id, api_key \\ nil) do
    id
    |> build_request(api_key)
    |> Delivery.send_request()
    |> parse_response
  end

  defp build_request(space_id, api_key) do
    url = space_id |> Delivery.url()
    {url, api_key |> Delivery.request_headers()}
  end

  defp parse_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        # parse to object here
        body |> json_library().decode! |> build_space

      {:ok, %Response{status_code: 401, body: body}} ->
        body |> Delivery.build_error(:unauthorized)

      {:ok, %Response{status_code: 404, body: body}} ->
        body |> Delivery.build_error(:not_found)

      {:ok, %Response{} = unknown_response} ->
        Delivery.build_error(unknown_response)
    end
  end

  defp build_space(%{
         "locales" => _locales,
         "name" => name,
         "sys" => %{"id" => id, "type" => "Space"}
       }) do
    {:ok, %Space{name: name, meta_data: %MetaData{id: id}}}
  end
end
