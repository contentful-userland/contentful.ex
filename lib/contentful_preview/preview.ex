defmodule Contentful.Preview do
  @moduledoc """
  The Preview API allows for fetching assets that are not yet published. The API should
  behave in parity with `Contentful.Delivery`.

  The API is _read only_.

  If you wish to manipulate data, please have a look at the `Contentful.Management`.

  ## Basic interaction

  The `space_id`, the `environment` and your `access_token` can all be configured in
  `config/config.exs`:

  ```
  # config/config.exs
  config :contentful, preview: [
    space_id: "<my_space_id>",
    environment: "<my_environment>",
    access_token: "<my_access_token>"
  ]
  ```

  The space can then be fetched as a `Contentful.Space` via a simple query:

  ```
  import Contentful.Query
  alias Contentful.Preview.Spaces

  {:ok, space} = Spaces |> fetch_one
  ```

  Retrieving items is then just a matter of importing `Contentful.Query`:

  ```
  import Contentful.Query
  alias Contentful.Preview.Entries

  {:ok, entries, total: _total_count_of_entries} = Entries |> fetch_all
  ```

  You can create query chains to form more complex queries:

  ```
  import Contentful.Query
  alias Contentful.Preview.Entries

  {:ok, entries, total: _total_count_of_entries} =
    Entries
    |> skip(2)
    |> limit(10)
    |> include(2)
    |> fetch_all
  ```
  """

  import HTTPoison, only: [get: 2]

  alias HTTPoison.Response

  @endpoint "preview.contentful.com"
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
  on the config/config.exs.

  """
  @spec json_library :: module()
  def json_library do
    Contentful.json_library()
  end

  @doc """
  constructs the base url with protocol for the CDA

  ## Examples

      "https://preview.contentful.com" = url()
  """
  @spec url() :: String.t()
  def url do
    "#{@protocol}://#{@endpoint}"
  end

  @doc """
  constructs the base url with the space id that got configured in config.exs
  """
  @spec url(nil) :: String.t()
  def url(space) when is_nil(space) do
    case space_from_config() do
      nil ->
        url()

      space ->
        space |> url
    end
  end

  @doc """
  constructs the base url with the extension for a given space
  ## Examples

      "https://preview.contentful.com/spaces/foo" = url("foo")
  """
  @spec url(String.t()) :: String.t()
  def url(space) do
    [url(), "spaces", space] |> Enum.join(@separator)
  end

  @doc """
  When explicilty given `nil`, will fetch the `environment` from the environments
  current config (see `config/config.exs`). Will fall back to `"master"` if no environment
  is set.

  ## Examples

    "https://preview.contentful.com/spaces/foo/environments/master" = url("foo", nil)

    # With config set in config/config.exs

    config :contentful, [ delivery, environment: "staging"]

    "https://preview.contentful.com/spaces/foo/environments/staging" = url("foo", nil)
  """
  @spec url(String.t(), nil) :: String.t()
  def url(space, env) when is_nil(env) do
    [space |> url(), "environments", environment_from_config()]
    |> Enum.join(@separator)
  end

  @doc """
  constructs the base url for the delivery endpoint for a given space and environment

  ## Examples

      "https://preview.contentful.com/spaces/foo/environments/bar" = url("foo", "bar")
  """
  def url(space, env) do
    [space |> url(), "environments", env] |> Enum.join(@separator)
  end

  @doc """
  Builds the request headers for a request against the CDA, taking api access tokens into account

  ## Examples
      my_access_token = "foobarfoob4z"
      [
         "Authorization": "Bearer foobarfoob4z",
         "User-Agent": "Contentful Elixir SDK",
         "Accept": "application/json"
       ] = my_access_token |> request_headers()
  """
  @spec request_headers(String.t()) :: keyword()
  def request_headers(api_key) do
    api_key
    |> authorization_header()
    |> Keyword.merge(@agent_header)
    |> Keyword.merge(@accept_header)
  end

  @doc """
  Sends a request against the CDA. It's really just a wrapper around `HTTPoison.get/2`
  """
  @spec send_request(tuple()) :: {:ok, Response.t()}
  def send_request({url, headers}) do
    get(url, headers)
  end

  @doc """
  Prevents parsing of empty options.

  ## Examples

      "" = collection_query_params([])

  """
  def collection_query_params([]) do
    ""
  end

  @doc """
  parses the options for retrieving a collection. It will drop any option that is not in
  @collection_filters ([:limit, :skip])

  ## Examples

      "?limit=50&skip=25&order=foobar"
        = collection_query_params(limit: 50, baz: "foo", skip: 25, order: "foobar", bar: 42)

  """
  @spec collection_query_params(
          limit: pos_integer(),
          skip: non_neg_integer(),
          content_type: String.t(),
          include: non_neg_integer()
        ) :: String.t()
  def collection_query_params(options) do
    params =
      options
      |> Keyword.take([:limit, :skip, :content_type, :include])
      |> URI.encode_query()

    "?#{params}"
  end

  @doc """
  Parses the response from the CDA and triggers a callback on success
  """
  @spec parse_response({:ok, Response.t()}, fun()) ::
          {:ok, struct()}
          | {:ok, list(struct()), total: non_neg_integer()}
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
  catch_all for any errors during flight (connection loss, etc.)
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

  defp api_key_from_configuration do
    config(:api_key, "")
  end

  defp environment_from_config do
    config(:environment, "master")
  end

  defp space_from_config do
    config(:space, nil)
  end

  @doc """
  Can be used to retrieve configuration for the `Contentful.Delivery` module

  ## Examples
      config :contentful, preview: [
        my_config: "foobar"
      ]

      "foobar" = Contentful.Preview.config(:my_config)
  """
  @spec config(atom(), any() | nil) :: any()
  def config(setting, default \\ nil) do
    config() |> Keyword.get(setting, default)
  end

  @doc """
  loads the configuration for the preview module from the contentful app configuration
  """
  @spec config() :: list(keyword())
  def config do
    Application.get_env(:contentful, :preview, [])
  end
end
