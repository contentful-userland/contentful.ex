defmodule Contentful.Delivery.Spaces do
  @moduledoc """
  Spaces provides function related to the reading of spaces 
  through the Contentful Delivery API
  """

  alias Contentful.{Delivery, Space}

  import Contentful.Delivery, only: [json_library: 0]
  alias HTTPoison.Response

  @doc """
    one() will retrieve one space by it's space id

    # Example

      iex> Contentful.Delivery.Spaces.one("space_id")
      %Contentful.Space{name: "a space name", _}
  """
  @spec one(String.t(), String.t()) ::
          {:ok, Space.t()} | {:error, atom(), list(keyword())}
  def one(id, api_key \\ nil) do
    id
    |> build_request(api_key)
    |> Delivery.send_request()
    |> parse_response
  end

  defp build_request(space_id, api_key) do
    url = "#{Delivery.url()}/spaces/#{space_id}"
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
    meta = %Contentful.MetaData{id: id}
    {:ok, %Contentful.Space{name: name, meta_data: meta}}
  end
end
