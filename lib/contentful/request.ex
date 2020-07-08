defmodule Contentful.Request do
  @moduledoc """
  Encapsulates functions invloved in making a request towards the Contentful APIs.
  """
  alias Contentful.Configuration
  alias Contentful.Query

  import Contentful.Misc, only: [fallback: 2]

  @agent_header [
    "User-Agent": "Contentful Elixir SDK"
  ]

  @accept_header [
    accept: "application/json"
  ]

  def collection_query_params([]) do
    ""
  end

  @doc """
  parses the options for retrieving a collection, usually triggered by a `Contentful.Query.fetch_all/4`.
  It will drop any option that is not in an allowed set of parameter options.

  ## Examples

      "?limit=50&skip=25&order=foobar"
        = collection_query_params(limit: 50, baz: "foo", skip: 25, order: "foobar", bar: 42)

  Also provides support for mapping out some of the API specific syntax in field handling.

  ## Examples

      "?sys.id[ne]=foobar" = collection_query_params(select_params: [id: [ne: "foobar"]])

  """
  @spec collection_query_params(
          limit: pos_integer(),
          skip: non_neg_integer(),
          include: non_neg_integer(),
          content_type: String.t(),
          query: String.t(),
          select_params: map()
        ) :: String.t()
  def collection_query_params(options) do
    filters =
      options
      |> Keyword.get(:select_params)
      |> fallback([])
      |> deconstruct_filters()

    params =
      options
      |> Keyword.take([:limit, :skip, :include, :content_type, :query])
      |> Keyword.merge(filters)
      |> URI.encode_query()

    "?#{params}"
  end

  @doc """
  Builds the request headers for a request against the CDA, taking api access tokens into account

  ## Examples
      my_access_token = "foobarfoob4z"
      [
         "Authorization": "Bearer foobarfoob4z",
         "User-Agent": "Contentful Elixir SDK",
         "Accept": "application/json"
       ] = my_access_token |> headers()
  """
  @spec headers(String.t()) :: keyword()
  def headers(api_key) do
    api_key
    |> authorization_header()
    |> Keyword.merge(@agent_header)
    |> Keyword.merge(@accept_header)
  end

  defp authorization_header(nil) do
    api_key_from_configuration() |> authorization_header()
  end

  defp authorization_header(token) do
    [authorization: "Bearer #{token}"]
  end

  defp api_key_from_configuration do
    Configuration.get(:api_key) |> fallback("___MISSING_API_KEY___")
  end

  defp deconstruct_filters(filters) do
    filters
    |> Enum.map(fn {field, value} = _filter ->
      mapped_value =
        case field do
          :id ->
            {:"sys.id", value}

          field_name ->
            {:"fields.#{field_name}", value}
        end

      case mapped_value do
        {field, value} when is_binary(value) ->
          {field, value}

        {field, [{modifier, modifier_value}]} when is_list(modifier_value) ->
          create_modified_field(field, modifier, Enum.join(modifier_value, ","))

        {field, [{modifier, modifier_value}]} ->
          create_modified_field(field, modifier, modifier_value)
      end
    end)
  end

  defp create_modified_field(field, modifier, field_value) do
    unless Query.allowed_filter_modifiers() |> Enum.member?(modifier) do
      raise %ArgumentError{
        message: """
        Invalid modifier for field '#{field}'!

            Allowed modifiers are: #{Query.allowed_filter_modifiers() |> Enum.join(", ")}
        """
      }
    end

    {:"#{field}[#{modifier}]", field_value}
  end
end
