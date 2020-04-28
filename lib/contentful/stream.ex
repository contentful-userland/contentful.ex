defmodule Contentful.Stream do
  alias Contentful.Delivery
  alias Contentful.Delivery.Spaces

  import Contentful.Query, only: [fetch_all: 4]

  def stream(
        queryable,
        space \\ Delivery.config(:space_id),
        env \\ Delivery.config(:environment),
        api_key \\ Delivery.config(:access_token)
      )

  def stream(Spaces, space, env, api_key) do
    {:error, [message: "Streaming a spaces collection is not supported"], total: 0}
  end

  def stream(
        {queryable, parameters} = context,
        space,
        env,
        api_key
      ) do
    Stream.resource(
      fn ->
        case context |> fetch_all(space, env, api_key) do
          {:ok, entities, total: total} ->
            {entities, {context, total, [space: space, env: env, api_key: api_key]}}

          {:error, _} ->
            {[], nil}
        end
      end,
      &process_page/1,
      fn _ -> nil end
    )
  end

  def stream(queryable, space, env, api_key) do
    stream({queryable, []}, space, env, api_key)
  end

  defp process_page({
         [head | tail] = val,
         {_context, _total, _meta} = parameters
       }) do
    {[head], {tail, parameters}}
  end

  defp process_page(
         {[],
          {
            {queryable, parameters} = context,
            total,
            [space: space, env: env, api_key: api_key] = meta
          }}
       ) do
    limit = parameters |> Keyword.get(:limit, 100)

    if limit < total do
      skip = parameters |> Keyword.get(:skip, 0)
      next_parameter = parameters |> Keyword.put(:skip, limit + skip)

      case {queryable, next_parameter} |> fetch_all(space, env, api_key) do
        {:ok, entities, _} -> {entities, {{queryable, next_parameter}, total, meta}}
        {:error, _} -> {[], nil}
      end
    else
      # we reached the end of the set, bail
      {:halt, []}
    end
  end

  defp process_page(acc) do
    process_page({[], acc})
  end
end
