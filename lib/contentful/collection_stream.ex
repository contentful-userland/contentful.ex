defmodule Contentful.CollectionStream do
  @moduledoc """
  A CollectionStream provides functions to make a Contentful.Collection streamable,
  allowing the user to just iterate over the pages of resources in the Contentful API.
  """
  alias Contentful.Space

  @callback stream(
              list(keyword()),
              Space.t() | String.t(),
              String.t(),
              String.t() | nil
            ) :: Stream.t()

  @doc """
  Allows for a callback function to be used as a resource and returns a Stream based on a resource.

  Constructs the `start` function, the `next` and the `after` function to construct the stream and
  keeps the state around for emitting individual items from pages fetched.
  """
  @spec stream_all(
          Space.t() | String.t(),
          fun(),
          list(keyword()),
          String.t(),
          String.t() | nil
        ) :: fun()
  def stream_all(space, func, options \\ [], env \\ nil, api_key \\ nil)

  def stream_all(space, func, options, env, api_key) do
    Stream.resource(
      fn -> fetch_page(space, func, options, env, api_key) end,
      &process_page/1,
      fn _ -> nil end
    )
  end

  defp process_page(
         {[],
          [
            total: total,
            options: opts,
            env: env,
            api_key: api_key,
            space: space,
            func: func
          ]}
       ) do
    skip = opts |> Keyword.get(:skip, 0)
    limit = opts |> Keyword.get(:limit, 100)

    if limit < total do
      space
      |> fetch_page(func, [limit: limit, skip: skip + limit], env, api_key)
    else
      {[], {[], nil}}
    end
  end

  defp process_page({[head | tail], meta}) do
    {[head], {tail, meta}}
  end

  defp process_page(_) do
    {:halt, nil}
  end

  @spec fetch_page(
          Space.t(),
          fun(),
          list(keyword()),
          String.t() | nil,
          String.t() | nil
        ) :: {list(), list(keyword())}
  defp fetch_page(space, func, options, env, api_key) do
    case options |> func.(space, env, api_key) do
      {:ok, items, total: total} ->
        {items,
         [
           total: total,
           options: options,
           env: env,
           api_key: api_key,
           space: space,
           func: func
         ]}

      {:error, _} ->
        {[], nil}
    end
  end
end
