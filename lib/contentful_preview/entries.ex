defmodule Contentful.Preview.Entries do
  @moduledoc """
  Entries allows for querying the entries of a space via `Contentful.Query`.

  Querying is the same as with `Contentful.Delivery.Entries`:

  ## Fetching a single entry

      import Contentful.Query
      alias Contentful.Preview.Entries

      {:ok, entry} = Entries |> fetch_one("my_entry_id")
  """

  alias Contentful.Queryable
  @behaviour Queryable

  @endpoint "/entries"

  @impl Queryable
  def endpoint, do: @endpoint

  @impl Queryable
  def resolve_collection_response(_) do
    {:ok, [%{}], [total: 1]}
  end

  @impl Queryable
  def resolve_entity_response(_) do
    {:ok, %{}}
  end
end
