defmodule Contentful.Delivery.ContentTypes do
  @moduledoc """
  Provides functions around reading content types from spaces
  """

  alias Contentful.{
    ContentType,
    Collection,
    CollectionStream,
    Delivery,
    MetaData,
    Space
  }

  @behaviour Collection
  @behaviour CollectionStream

  @doc """
  Used to query all the content types for a given `Contentful.Space`

  Supports collection parameters for `:skip` and `:limit`. Will eagerly call the API.

  ## Examples

      # fetches all content types by a given space id
      {:ok, [%Contentful.ContentType{description: "a description"}], total: _} 
        = ContentTypes.fetch_all("a space_id")

      # with collection params
      space = "my_space_id"
      {:ok, [%ContentType{ description: "first one"} | _], total: 3} 
        = space |> ContentTypes.fetch_all()

      {:ok, [
        %ContentType{ description: "first one"}}, 
        %ContentType{ description: "second one"}}, 
        %ContentType{ description: "third one"}}
      ], total: 3} = space |> ContentTypes.fetch_all
      
      {:ok, [
        %ContentType{ description: "second one"}}, 
        %ContentType{ description: "third one"}}
      ], total: 3} = space |> ContentTypes.fetch_all(skip: 1)

      {:ok, [
        %ContentType{ description: "first one" }
      ], total: 3} = space |> ContentTypes.fetch_all(limit: 1)

      {:ok, [
        %ContentType{ description: "third one" }
      ], total: 3} = space |> ContentTypes.fetch_all(limit: 1, skip: 2)
  """
  @impl Collection
  @spec fetch_all(
          Space.t() | String.t(),
          String.t(),
          String.t() | nil,
          String.t() | nil
        ) ::
          {:ok, list(ContentType.t())}
          | {:error, atom(), original_message: String.t()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, :unknown}

  def fetch_all(space, options \\ [], env \\ nil, api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: id}}, options, env, api_key) do
    id
    |> build_multiple_request(options, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_content_types/1)
  end

  def fetch_all(space_id, options, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, options, env, api_key)
  end

  @doc """
  Used to fetch a single ContentType by a space

  ## Examples

      # fetches a content type for a space given
      iex> {:ok, %Space{} = space} = Spaces.fetch_one("a_space_id")
      {:ok, %ContentType{description: "a description"}} 
        = space |> ContentTypes.fetch_one("my_content_type_id")
  """
  @impl Collection
  @spec fetch_one(
          Space.t() | String.t(),
          String.t(),
          String.t() | nil,
          String.t() | nil
        ) ::
          {:ok, ContentType.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, :unknown}

  def fetch_one(space, content_type_id, env \\ nil, api_key \\ nil)

  def fetch_one(%Space{meta_data: %{id: id}}, content_type_id, env, api_key) do
    content_type_id
    |> build_single_request(id, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_content_type/1)
  end

  def fetch_one(space_id, content_type_id, env, api_key) do
    fetch_one(%Space{meta_data: %{id: space_id}}, content_type_id, env, api_key)
  end

  @doc """
  Constructs a stream around __all content types__ of a `Contentful.Space`.

  Will return a stream of content types that can be composed with the standard libraries functions. 
  This function calls the API endpoint for content types on demand, e.g. until the upper limit 
  (the total of all content types) is reached.

  __Warning__: With very large entry collections, this can quickly run into the request limit of the API! 

  ## Examples
      space = "my_space_id"
      # API calls calculated by the stream (in this case two calls)
      ["first_content_type", "second_content_type"] 
        = space 
          |> ContentTypes.stream(limit: 1) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(2) 

      environment = "staging"
      api_token = "foobar?foob4r"
      ["first_content_type"] 
        = space 
          |> ContentTypes.stream(limit: 1, environment, api_token) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(2) 
    
      # Use the :limit parameter to set the page size 
      ["first_content_type", "second_content_type", "third_content_type", "fourth_content_type"] 
        = space 
          |> ContentTypes.stream(limit: 4) 
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end) 
          |> Enum.take(4) 
    
  """
  @impl CollectionStream
  def stream(space, options \\ [], env \\ nil, api_key \\ nil) do
    space |> CollectionStream.stream_all(&fetch_all/4, options, env, api_key)
  end

  defp build_multiple_request(space, options, env, api_key) do
    url = [
      space |> Delivery.url(env),
      "/content_types",
      options |> Delivery.collection_query_params()
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_single_request(content_type_id, space, env, api_key) do
    url = [
      space |> Delivery.url(env),
      "/content_types",
      "/#{content_type_id}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_content_types(%{"items" => items, "total" => total}) do
    content_types =
      items
      |> Enum.map(&build_content_type/1)
      |> Enum.map(fn {:ok, ct} -> ct end)

    {:ok, content_types, total: total}
  end

  defp build_content_type(%{
         "name" => name,
         "description" => description,
         "displayField" => display_field,
         "sys" => %{"id" => id, "revision" => rev},
         "fields" => fields
       }) do
    {:ok,
     %ContentType{
       name: name,
       description: description,
       display_field: display_field,
       fields: Enum.map(fields, &build_field/1),
       meta_data: %MetaData{id: id, revision: rev}
     }}
  end

  defp build_field(%{
         "required" => req,
         "name" => name,
         "localized" => loc,
         "disabled" => disabled,
         "omitted" => omit,
         "type" => type
       }) do
    %ContentType.Field{
      required: req,
      name: name,
      localized: loc,
      disabled: disabled,
      omitted: omit,
      type: type,
      validations: []
    }
  end
end
