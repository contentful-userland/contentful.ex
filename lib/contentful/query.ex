defmodule Contentful.Query do
  alias Contentful.Delivery
  alias Contentful.ContentType
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
        {queryable, parameters},
        space \\ Delivery.config(:space_id),
        env \\ Delivery.config(:environment),
        api_key \\ Delivery.config(:access_token)
      ) do
    url = [
      space |> Delivery.url(env),
      queryable.endpoint(),
      parameters |> Delivery.collection_query_params()
    ]

    {url, api_key |> Delivery.request_headers()}
    |> Delivery.send_request()
    |> Delivery.parse_response(&queryable.build_entries/1)
  end
end
