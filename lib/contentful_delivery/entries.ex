defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Collects functions around the reading of entries from a `Contentful.Space`
  """
  alias Contentful.{
    Collection,
    CollectionStream,
    Delivery,
    Entry,
    MetaData,
    Space
  }

  @behaviour Collection
  @behaviour CollectionStream

  @doc """
  Will fetch a single entry for a given Contentful.Space within an `environment`.

  Actually fetches the entry eagerly and will call the API immediately.

  ## Examples

      space = "my_space_id"
      {:ok, %Entry{ meta_data: %MetaData{ id: "my_entry_id"}}}
        = space |> Entries.fetch_one("my_entry_id")

      # for envs other than "master"
      environment =  "staging"
      {:ok, %Entry{ meta_data: %MetaData{ id: "my_entry_id"}}}
        = space |> Entries.fetch_one("my_entry_id", environment)

      # override access token
      environment =  "my_personal_env"
      my_access_token = "foobarBAZ"
      {:ok, %Entry{ meta_data: %MetaData{ id: "my_entry_id"}}}
        = space |> Entries.fetch_one("my_entry_id", environment, my_access_token)


  """
  @impl Collection
  @spec fetch_one(
          String.t(),
          Space.t() | String.t(),
          String.t() | nil,
          String.t() | nil
        ) ::
          {:ok, Entry.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, :unknown}

  def fetch_one(
        entry_id,
        space_id \\ Delivery.from_config(:space),
        env \\ Delivery.from_config(:environment),
        api_key \\ Delivery.from_config(:access_token)
      )

  def fetch_one(entry_id, %Space{meta_data: %{id: space_id}}, env, api_key) do
    space_id
    |> build_single_request(entry_id, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_entry/1)
  end

  def fetch_one(entry_id, space_id, env, api_key) do
    fetch_one(entry_id, %Space{meta_data: %{id: space_id}}, env, api_key)
  end

  @doc """
  Can be used fetch all entries associated with a `Contentful.Space` __that are **published**__.

  Will take basic collection filters into account, specifically `:limit` and `:skip` to traverse and
  limit the collection of entries.

  Will fetch a single page as defined by its params and will fetch it eagerly (calls the API immediately.).

  ## Examples
      {:ok, [
        %Entry{ meta_data: %{ id: "foobar_0"}},
        %Entry{ meta_data: %{ id: "foobar_1"}},
        %Entry{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Entries.fetch_all

      {:ok, [
        %Entry{ meta_data: %{ id: "foobar_1"}},
        %Entry{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Entries.fetch_all(skip: 1)

      {:ok, [
        %Entry{ meta_data: %{ id: "foobar_0"}}
      ], total: 3} = space |> Entries.fetch_all(limit: 1)

      {:ok, [
        %Entry{ meta_data: %{ id: "foobar_2"}}
      ], total: 3} = space |> Entries.fetch_all(limit: 1, skip: 2)
  """
  @impl Collection
  @spec fetch_all(
          list(keyword()),
          Space.t() | String.t(),
          String.t() | nil,
          String.t() | nil
        ) ::
          {:ok, list(Entry.t())}
          | {:error, atom(), original_message: String.t()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, :unknown}

  def fetch_all(
        options \\ [],
        space \\ Delivery.from_config(:space),
        env \\ Delivery.from_config(:environment),
        api_key \\ Delivery.from_config(:access_token)
      )

  def fetch_all(options, %Space{meta_data: %{id: space_id}}, env, api_key) do
    space_id
    |> build_multi_request(options, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_entries/1)
  end

  def fetch_all(options, space_id, env, api_key)
      when is_binary(space_id) do
    fetch_all(options, %Space{meta_data: %{id: space_id}}, env, api_key)
  end

  @doc """
  Constructs a stream around __all entries__ of a `Contentful.Space` __that are published__.

  Will return a stream of entries that can be composed with the standard libraries functions.
  This function calls the API endpoint for entries on demand, e.g. until the upper limit
  (the total of all entries) is reached.

  __Warning__: With very large entry collections, this can quickly run into the request limit of the API!

  ## Examples

      # uses the configured space for streaming
      Entries.stream() |> Enum.take(1)

      space = "my_space_id"
      # API calls calculated by the stream (in this case two calls)
      ["first_entry_id", "second_entry_id"] =
          Entries.stream([limit: 1], space)
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end)
          |> Enum.take(2)

      environment = "staging"
      api_token = "foobar?foob4r"
      ["first_entry_id"] =
          Entries.stream([limit: 1], space, environment, api_token)
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end)
          |> Enum.take(2)

      # Use the :limit parameter to set the page size
      ["first_entry_id", "second_entry_id", "third_entry_id", "fourth_entry_id"] =
          Entries.stream([limit: 4], space)
          |> Stream.map(fn %{ meta_data: %{ id: id }} -> id end)
          |> Enum.take(4)

  """
  @impl CollectionStream
  def stream(
        options \\ [],
        space \\ Delivery.from_config(:space),
        env \\ Delivery.from_config(:environment),
        api_key \\ Delivery.from_config(:access_token)
      ) do
    space |> CollectionStream.stream_all(&fetch_all/4, options, env, api_key)
  end

  defp build_single_request(space_id, entry_id, env, api_key) do
    url = [
      space_id |> Delivery.url(env),
      "/entries/#{entry_id}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_multi_request(space, options, env, api_key) do
    url = [
      space |> Delivery.url(env),
      "/entries",
      options |> Delivery.collection_query_params()
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_entries(%{"total" => total, "items" => items}) do
    entries =
      items
      |> Enum.map(&build_entry/1)
      |> Enum.map(fn {:ok, entry} -> entry end)

    {:ok, entries, total: total}
  end

  defp build_entry(%{
         "fields" => fields,
         "sys" => %{"id" => id, "revision" => rev}
       }) do
    {:ok,
     %Entry{
       fields: fields,
       meta_data: %MetaData{id: id, revision: rev}
     }}
  end
end
