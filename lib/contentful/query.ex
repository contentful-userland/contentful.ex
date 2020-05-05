defmodule Contentful.Query do
  require Logger

  @moduledoc """
  This module provides the chainable query syntax for building queries against the
  APIs of Contentful.

  The chains will then be serialized to a URL and send to the API. A basic query looks like this:

  ```
  Entity
  |> skip(3)
  |> limit(2)
  |> fetch_all
  ```

  wherein `Entity` is one of the modules that exhibit `Contentful.Queryable` behaviour, such as
  `Contentful.Delivery.Entries`, `Contentful.Delivery.Assets` and `Contentful.Delivery.ContentTypes`.

  As an example, querying all entries of a given `Contentful.Space` (represented by its `space_id`) can
  be done as follows:

  ```
  Contentful.Delivery.Entries
  |> fetch_all(space_id)
  ```

  """
  alias Contentful.ContentType
  alias Contentful.Delivery
  alias Contentful.Delivery.Entries
  alias Contentful.Delivery.Spaces
  alias Contentful.Space
  alias Contentful.SysData

  @doc """
  adds the `include` parameter to a query.

  This allows for fetching associated items up to a collection of `Contentful.Entry`.

  The `include` call will _only_ work with `Contentful.Delivery.Entries`, as it is meaningless to
  other entities.

  ## Example:
      alias Contentful.Delivery.Entries
      Entries |> include(2) |> fetch_all

      # translates in the background to

      "<api_url>/entries?include=2"

  """
  @spec include({Entries, list()}, integer()) :: {Entries, list()}
  def include(queryable, number \\ 1)

  def include({Entries, parameters}, number) do
    if number > 10 do
      raise(ArgumentError, "Include depth cannot be higher than 10!")
    end

    {Entries, parameters |> Keyword.put(:include, number)}
  end

  def include(Entries, number) do
    include({Entries, []}, number)
  end

  def include(queryable, _number) do
    queryable
  end

  @doc """
  adds the `limit` parameter to a call, limiting the amount of entities returned.
  The caller will still retreive the total amount of entities, if successful.

  The limit defaults to `1000`, the maximum `limit` allowed for API calls.

  ## Examples
      alias Contentful.Delivery.Assets
      Assets |> limit(2) |> fetch_all

      # translates in the background to

      "<api_url>/assets?limit=2"
  """
  @spec limit({module(), list()}, integer()) :: {module(), list()}
  def limit(queryable, number \\ 1000)

  def limit({queryable, parameters}, number) do
    {queryable, parameters |> Keyword.put(:limit, number)}
  end

  def limit(queryable, number) do
    limit({queryable, []}, number)
  end

  @doc """
  adds the `skip` parameter to API calls, allowing to skip over a number of entities, effectively
  allowing the implementation of pagination if desired.

  ## Examples
      alias Contentful.Delivery.Assets
      Assets |> skip(10) |> fetch_all

      # translates in the background to a call to the API

      "<api_url>/assets?skip=10"
  """
  @spec skip({module(), list()}, non_neg_integer()) :: {module(), list()}
  def skip({queryable, parameters}, number) do
    {queryable, parameters |> Keyword.put(:skip, number)}
  end

  def skip(queryable, number) do
    skip({queryable, []}, number)
  end

  @doc """
  adds a `content_type` parameter for filtering sets of `Contentful.Entry`
  by a `Contentful.ContentType`, effectively allowing for scoping by content type.

  `content_type` will only work with `Contentful.Delivery.Entries` at the moment.

  ## Examples
      alias Contentful.Delivery.Entries
      Entries |> content_type("foobar") |> fetch_all

      # translates in the background to

      "<api_url>/entries?content_type=foobar"

      # also works with passing `Contentful.ContentType`:

      my_content_type = %Contentful.ContentType{sys: %Contentful.SysData{id: "foobar"}}
      Entries |> content_type(my_content_type) |> fetch_all
  """
  @spec content_type({Entries, list()}, String.t() | ContentType.t()) :: {Entries, list()}
  def content_type({Entries, parameters}, c_type) when is_binary(c_type) do
    {Entries, parameters |> Keyword.put(:content_type, c_type)}
  end

  def content_type({Entries, parameters}, %ContentType{sys: %SysData{id: value}} = _c_type) do
    content_type({Entries, parameters}, value)
  end

  def content_type(Entries, c_type) do
    content_type({Entries, []}, c_type)
  end

  def content_type(queryable, _c_type) do
    queryable
  end

  @doc """
  will __resolve__ a query chain by eagerly calling the API and resolving the response immediately

  ## Examples
      alias Contentful.Delivery.Entries
      {:ok, entries, total: _total_count_of_entries} =
        Entries |> content_type("foobar") |> limit(1) |> fetch_all
  """
  @spec fetch_all({module(), list()}, String.t(), String.t(), String.t()) ::
          {:ok, list(struct()), total: non_neg_integer()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, atom(), original_message: String.t()}
  def fetch_all(
        queryable,
        space \\ Delivery.config(:space_id),
        env \\ Delivery.config(:environment),
        api_key \\ Delivery.config(:access_token)
      )

  def fetch_all({Spaces, _}, _, _, _) do
    {:error, [message: "Fetching a spaces collection is not supported, use fetch_one/1 instead"],
     total: 0}
  end

  def fetch_all(queryable, %Space{sys: %SysData{id: space}}, env, api_key) do
    fetch_all(queryable, space, env, api_key)
  end

  def fetch_all(
        {queryable, parameters},
        space,
        env,
        api_key
      ) do
    url = [
      space |> Delivery.url(env),
      queryable.endpoint(),
      parameters |> Delivery.collection_query_params()
    ]

    {url, api_key |> Delivery.request_headers()}
    |> Delivery.send_request()
    |> Delivery.parse_response(&queryable.resolve_collection_response/1)
  end

  def fetch_all(queryable, space, env, api_key) do
    fetch_all({queryable, []}, space, env, api_key)
  end

  @doc """
  will __resolve__ a query chain by eagerly calling the API asking for _one_ entity

  ## Examples
      import Contentful.Query
      alias Contentful.Delivery.{Spaces, Entries}

      # Note: Spaces is the only Queryable that can be fetched without an id
      Spaces |> fetch_one

      # all others would throw an error, so an id has to be passed:
      Entries |> fetch_one("my_entry_id")
  """
  @spec fetch_one(module(), String.t() | nil, String.t(), String.t(), String.t()) ::
          {:ok, struct()}
          | {:error, :rate_limit_exceeded, wait_for: integer()}
          | {:error, atom(), original_message: String.t()}
  def fetch_one(
        queryable,
        id \\ nil,
        space \\ Delivery.config(:space_id),
        env \\ Delivery.config(:environment),
        api_key \\ Delivery.config(:access_token)
      )

  def fetch_one(queryable, id, %Space{sys: %SysData{id: space_id}}, env, api_key) do
    fetch_one(queryable, id, space_id, env, api_key)
  end

  def fetch_one(
        queryable,
        id,
        space,
        env,
        api_key
      ) do
    url =
      case {queryable, id} do
        {Spaces, nil} ->
          [space |> Delivery.url()]

        {Spaces, id} ->
          [id |> Delivery.url()]

        {_queryable, nil} ->
          raise ArgumentError, "id is missing!"

        {{module, _parameters}, id} ->
          # drops the parameters, as single query responses don't allow parameters
          [space |> Delivery.url(env), module.endpoint(), "/#{id}"]

        _ ->
          [space |> Delivery.url(env), queryable.endpoint(), "/#{id}"]
      end

    # since you can pass compose into fetch one, we strip extra params here
    queryable =
      case queryable do
        {module, parameters} ->
          Logger.warn("Stripping parameters: #{inspect(parameters)}")
          module

        _ ->
          queryable
      end

    {url, api_key |> Delivery.request_headers()}
    |> Delivery.send_request()
    |> Delivery.parse_response(&queryable.resolve_entity_response/1)
  end

  @doc """
  will __resolve__ a query chain by constructing a `Stream.resource` around a possible API response
  allowing for lazy evaluation of queries. Cann be helpful with translating collection calls of
  unknown size.

  Be careful when using this, as one can run into API rate limits quickly for very large sets.

  ## Examples

      import Contentful.Query
      alias Contentful.Delivery.{Assets, Spaces}

      # translates into two api calls in the background
      Assets |> stream |> Enum.take(2000)

      # you can use limit() to set the page size, in the example, stream would call the API
      # 10 times total.
      Assets |> limit(100) |> Enum.take(1000)

      # will not work with Spaces, though, as they

  """
  @spec stream(tuple(), String.t(), String.t(), String.t()) ::
          Enumerable.t()
  def stream(
        queryable,
        space \\ Delivery.config(:space_id),
        env \\ Delivery.config(:environment),
        api_key \\ Delivery.config(:access_token)
      )

  def stream(Spaces, _space, _env, _api_key) do
    {:error, [message: "Streaming a spaces collection is not supported"], total: 0}
  end

  def stream(args, space, env, api_key) do
    Contentful.Stream.stream(args, space, env, api_key)
  end
end
