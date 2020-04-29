defmodule Contentful.Query do
  alias Contentful.Delivery
  alias Contentful.Delivery.Spaces
  alias Contentful.ContentType
  alias Contentful.Space
  alias Contentful.SysData

  def include({queryable, parameters}, number) do
    {queryable, parameters |> Keyword.put(:include, number)}
  end

  def include(queryable, number) do
    include({queryable, []}, number)
  end

  def limit(queryable, number \\ 1000)

  def limit({queryable, parameters}, number) do
    {queryable, parameters |> Keyword.put(:limit, number)}
  end

  def limit(queryable, number) do
    limit({queryable, []}, number)
  end

  def skip({queryable, parameters}, number) do
    {queryable, parameters |> Keyword.put(:skip, number)}
  end

  def skip(queryable, number) do
    skip({queryable, []}, number)
  end

  def content_type({queryable, parameters}, c_type) when is_binary(c_type) do
    {queryable, parameters |> Keyword.put(:content_type, c_type)}
  end

  def content_type({queryable, parameters}, %ContentType{sys: %SysData{id: value}} = _c_type) do
    content_type({queryable, parameters}, value)
  end

  def content_type(queryable, c_type) do
    content_type({queryable, []}, c_type)
  end

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

  def fetch_all(context, %Space{sys: %SysData{id: space}}, env, api_key) do
    fetch_all(context, space, env, api_key)
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

        {_queryable, id} ->
          [space |> Delivery.url(env), queryable.endpoint(), "/#{id}"]
      end

    {url, api_key |> Delivery.request_headers()}
    |> Delivery.send_request()
    |> Delivery.parse_response(&queryable.resolve_entity_response/1)
  end

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
