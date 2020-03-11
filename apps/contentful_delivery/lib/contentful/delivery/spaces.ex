defmodule Contentful.Delivery.Spaces do
  @moduledoc """
  Spaces provides function related to the reading of spaces 
  through the Contentful Delivery API
  """

  alias Contentful.Space
  import HTTPoison, only: [get: 2]
  import Contentful.Delivery, only: [json_library: 0]
  alias HTTPoison.Response

  @endpoint "cdn.contentful.com"
  @protocol "https"

  @agent_header [
    "User-Agent": "Contentful Elixir SDK"
  ]

  @accept_header [
    accept: "application/json"
  ]

  @doc """
  one() will retrieve one space by it's space id
  """
  @spec one(String.t()) :: {:ok, Space.t()} | {:error, String.t(), String.t()}
  def one(id) do
    id
    |> build_request
    |> send_request
    |> parse_response
  end

  defp build_request(space_id) do
    headers =
      api_key()
      |> authorization_header()
      |> IO.inspect()
      |> Keyword.merge(@agent_header)
      |> Keyword.merge(@accept_header)

    url = "#{@protocol}://#{@endpoint}/spaces/#{space_id}"
    {url, headers}
  end

  defp send_request({url, headers}) do
    get(url, headers)
  end

  defp authorization_header(token) do
    [
      authorization: "Bearer #{token}"
    ]
  end

  defp parse_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        # parse to object here
        body |> json_library().decode!

      {:ok, %Response{status_code: 401, body: body}} ->
        body |> make_error(:unauthorized)

      {:ok, %Response{status_code: 403, body: body}} ->
        body |> make_error(:unauthorized)

      {:ok, %Response{status_code: 404, body: body}} ->
        body |> make_error(:not_found)

      _ ->
        make_error()
    end
  end

  defp api_key() do
    Application.get_env(:contentful_delivery, :access_token, "")
  end

  defp make_error(response_body, status) do
    {:ok, %{"message" => message}} = response_body |> json_library().decode()
    {:error, status, original_message: message}
  end

  defp make_error do
    {:error, :unknown}
  end
end
