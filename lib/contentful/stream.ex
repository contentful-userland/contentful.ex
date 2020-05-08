defmodule Contentful.Stream do
  @moduledoc """
  This module extracts the stream functionality from the `Contentful.Query` providing the underlying
  functions for the streaming functionality of collectable entities from the Contentful API.
  """
  import Contentful.Query, only: [fetch_all: 4]

  @doc """
  Entrypoint for constructing a stream, see `Contentful.Query.stream/4`.
  """
  def stream(
        {_queryable, _params} = context,
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
         [head | tail],
         {_context, _total, _meta} = parameters
       }) do
    {[head], {tail, parameters}}
  end

  defp process_page(
         {[],
          {
            {queryable, parameters},
            total,
            [space: space, env: env, api_key: api_key] = meta
          }}
       ) do
    limit = parameters |> Keyword.get(:limit, 1000)

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

  defp process_page(_) do
    {:halt, nil}
  end
end
