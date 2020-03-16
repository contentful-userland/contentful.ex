defmodule Contentful.Delivery do
  @moduledoc """
  Documentation for `Contentful.Delivery`.
  """

  import HTTPoison, only: [get: 2]

  alias HTTPoison.Response

  @endpoint "cdn.contentful.com"
  @protocol "https"
  @separator "/"

  @agent_header [
    "User-Agent": "Contentful Elixir SDK"
  ]

  @accept_header [
    accept: "application/json"
  ]

  @doc """
  Gets the json library for the Contentful Delivery API based 
  on the config/config.exs. Will override the central configuration
  option if set.

  """
  @spec json_library :: module()
  def json_library do
    Contentful.json_library(:contentful_delivery)
  end

  @doc """
  constructs the base url with protocol for the CDA

  ## Examples

      "https://cdn.contentful.com" = Contentful.Delivery.url()
  """
  @spec url() :: String.t()
  def url do
    "#{@protocol}://#{@endpoint}"
  end

  @doc """
  constructs the base url with the extension for a given space
  ## Examples

      "https://cdn.contentful.com/spaces/foo" = Contentful.Delivery.url("foo")
  """
  @spec url(String.t()) :: String.t()
  def url(space) do
    [url(), "spaces", space] |> Enum.join(@separator)
  end

  @doc """
  constructs the base url for the delivery endpoint for a given space and environment

  ## Examples

      "https://cdn.contentful.com/spaces/foo/environments/bar" = Contentful.Delivery.url("foo", "bar")
  """
  def url(space, env) do
    [space |> url(), "environments", env] |> Enum.join(@separator)
  end

  @doc """
    Build the request headers for a request against the CDA. 
  """
  @spec request_headers(String.t()) :: keyword()
  def request_headers(api_key) do
    api_key
    |> authorization_header()
    |> Keyword.merge(@agent_header)
    |> Keyword.merge(@accept_header)
  end

  @doc """
    Sends a request against the CDA
  """
  @spec send_request(tuple()) :: {:ok, Response.t()}
  def send_request({url, headers}) do
    get(url, headers)
  end

  @doc """
  parses the response from the CDA and triggers a callback on success
  """
  @spec parse_response({:ok, Response.t()}, fun()) ::
          {:ok, struct() | list(struct())}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, atom(), original_message: String.t()}
  def parse_response(
        {:ok, %Response{status_code: code, body: body} = resp},
        callback
      ) do
    case code do
      200 ->
        body |> json_library().decode! |> callback.()

      401 ->
        body |> build_error(:unauthorized)

      404 ->
        body |> build_error(:not_found)

      _ ->
        resp |> build_error()
    end
  end

  @doc """
  catch all for any errors furing flight (conneciton loss, etc.)
  """
  @spec parse_response({:error, any()}, fun()) :: {:error, :unknown}
  def parse_response({:error, _}, _callback) do
    build_error()
  end

  @doc """
    Used to construct generic errors for calls against the CDA
  """
  @spec build_error(String.t(), atom()) ::
          {:error, atom(), original_message: String.t()}
  def build_error(response_body, status) do
    {:ok, %{"message" => message}} = response_body |> json_library().decode()
    {:error, status, original_message: message}
  end

  @doc """
    Used for the rate limit exceeded error, as it gives the user extra information on wait times
  """
  @spec build_error(Response.t()) ::
          {:error, :rate_limit_exceeded, wait_for: integer()}
  def build_error(%Response{
        status_code: 429,
        headers: [{"x-contentful-rate-limit-exceeded", seconds}, _]
      }) do
    {:error, :rate_limit_exceeded, wait_for: seconds}
  end

  @doc """
    Used to make a generic error, in case the API Response is not what is expected
  """
  @spec build_error() :: {:error, :unknown}
  def build_error do
    {:error, :unknown}
  end

  defp authorization_header(token) when is_nil(token) do
    api_key_from_configuration() |> authorization_header()
  end

  defp authorization_header(token) do
    [authorization: "Bearer #{token}"]
  end

  defp api_key_from_configuration() do
    Application.get_env(:contentful_delivery, :access_token, "")
  end
end
