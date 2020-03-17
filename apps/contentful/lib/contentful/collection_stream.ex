defmodule Contentful.CollectionStream do
  alias Contentful.Space

  @callback stream(
              Space.t() | String.t(),
              list(keyword()),
              String.t(),
              String.t() | nil
            ) :: Stream.t()

  @spec stream_all(
          Space.t() | String.t(),
          fun(),
          list(keyword()),
          String.t(),
          String.t() | nil
        ) :: Stream.t()
  def stream_all(space, func, options \\ [], env \\ "master", api_key \\ nil)

  def stream_all(space, func, options, env, api_key) do
    options = options |> Keyword.put_new(:skip, 0) |> Keyword.put_new(:limit, 100)

    Stream.resource(
      fn -> fetch_page(space, func, options, env, api_key) end,
      &process_page/1,
      fn _ -> nil end
    )
  end

  defp process_page({[], nil}) do
    {:halt, nil}
  end

  defp process_page(
         {[], total: total, options: opts, env: env, api_key: api_key, space: space, func: func}
       ) do
    limit = opts[:limit]
    skip = opts[:skip]

    if limit < total do
      space
      |> fetch_page(func, [skip: skip + limit, limit: limit], env, api_key)
    else
      {[], {[], nil}}
    end
  end

  defp process_page({[head | tail], meta}) do
    {[head], {tail, meta}}
  end

  defp fetch_page(space, func, options, env, api_key) do
    case space |> func.(options, env, api_key) do
      {:ok, items, total: total} ->
        {items,
         total: total, options: options, env: env, api_key: api_key, space: space, func: func}

      {:error, _} ->
        {[], nil}
    end
  end
end
